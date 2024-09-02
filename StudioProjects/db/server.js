require('dotenv').config();
const express = require('express');
const app = express();
const port = 3000;
const db = require('./db');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { check, validationResult } = require('express-validator');
const nodemailer = require('nodemailer');
const crypto = require('crypto');
app.use(cors());
app.use(express.json());

// Middleware pour vérifier le token JWT
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  if (!authHeader) return res.sendStatus(401);

  const token = authHeader.split(' ')[1];
  if (!token) return res.sendStatus(401);

  jwt.verify(token, process.env.ACCESS_TOKEN_SECRET, (err, user) => {
    if (err) return res.sendStatus(403);
    
    // Assure-toi que 'user' contient une propriété 'role'
    if (!user.role) {
      console.error('Le token ne contient pas de rôle.');
      return res.status(400).json({ error: "Token invalide : rôle manquant" });
    }

    req.user = user;
    next();
  });
};

const generateAccessToken = (user) => {
  // Assure-toi que 'user' contient bien 'username' et 'role'
  if (!user.username || !user.role) {
    throw new Error("L'utilisateur doit avoir un nom d'utilisateur et un rôle pour générer un token.");
  }
  
  return jwt.sign(
    { username: user.username, role: user.role }, 
    process.env.ACCESS_TOKEN_SECRET, 
    { expiresIn: '1h' }
  );
};



// Middleware pour vérifier le rôle de l'administrateur
const isAdmin = (req, res, next) => {
  console.log('User from req.user:', req.user);

  if (req.user && req.user.role && req.user.role.toLowerCase() === 'admin') {
    next();
  } else {
    console.error('Accès interdit :', req.user ? req.user.role : 'Utilisateur non défini');
    res.status(403).json({ error: 'Accès interdit' });
  }
};


// Route pour demander une réinitialisation de mot de passe
app.post('/reset-password', async (req, res) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({ error: 'L\'email est requis.' });
  }

  try {
    const [user] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
    if (user.length === 0) {
      return res.status(404).json({ error: 'Utilisateur non trouvé avec cet email.' });
    }

    // Générer un token de réinitialisation
    const resetToken = crypto.randomBytes(20).toString('hex');
    const expires = Date.now() + 3600000; // Token valide pendant 1 heure

    await db.query('UPDATE users SET resetToken = ?, resetTokenExpires = ? WHERE email = ?', [resetToken, expires, email]);

    // Envoyer l'email de réinitialisation
    const transporter = nodemailer.createTransport({
      service: 'Gmail', // Utilisez le service que vous préférez
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
    });

    const mailOptions = {
      to: email,
      from: 'no-reply@yourapp.com',
      subject: 'Réinitialisation du mot de passe',
      text: `Vous recevez cet email parce que vous avez demandé la réinitialisation du mot de passe pour votre compte.\n\n
      Cliquez sur ce lien ou copiez-le dans votre navigateur pour réinitialiser votre mot de passe :\n\n
      http://${req.headers.host}/reset-password/${resetToken}\n\n
      Si vous n'avez pas demandé cette réinitialisation, veuillez ignorer cet email.\n`,
    };

    await transporter.sendMail(mailOptions);

    res.status(200).json({ message: 'Un lien de réinitialisation a été envoyé à votre email.' });
  } catch (err) {
    console.error('Erreur lors de la demande de réinitialisation de mot de passe:', err);
    res.status(500).json({ error: 'Erreur lors de la demande de réinitialisation de mot de passe' });
  }
});

// Route d'inscription avec gestion du premier utilisateur
app.post('/register', [
  check('id').notEmpty().withMessage('ID est requis'),
  check('username').notEmpty().withMessage('Username est requis'),
  check('password').notEmpty().withMessage('Mot de passe est requis')
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { id, username, password } = req.body;

  try {
    const [existingUser] = await db.query('SELECT * FROM users WHERE username = ?', [username]);
    if (existingUser.length > 0) {
      return res.status(409).json({ error: 'Utilisateur déjà existant avec ce username' });
    }

    const firstUser = await isFirstUser();
    const finalRole = firstUser ? 'admin' : 'caissier'; // Utilisation de 'caissier'

    const hash = await bcrypt.hash(password, 10);
    await db.query('INSERT INTO users (id, username, password, role) VALUES (?, ?, ?, ?)', [id, username, hash, finalRole]);

    res.status(201).json({ id, username, role: finalRole });
  } catch (err) {
    console.error('Erreur lors de l\'inscription:', err);
    res.status(500).json({ error: 'Erreur lors de l\'inscription' });
  }
});

// Fonction pour vérifier s'il s'agit du premier utilisateur
const isFirstUser = async () => {
  try {
    const [rows] = await db.query('SELECT COUNT(*) as count FROM users');
    return rows[0].count === 0;
  } catch (err) {
    console.error('Erreur lors de la vérification du premier utilisateur:', err);
    throw err;
  }
};

// Route de connexion
app.post('/login', [
  check('username').notEmpty().withMessage('Username est requis'),
  check('password').notEmpty().withMessage('Mot de passe est requis')
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { username, password } = req.body;

  try {
    const [rows] = await db.query('SELECT * FROM users WHERE username = ?', [username]);

    if (rows.length === 0) {
      return res.status(401).json({ error: 'Nom d\'utilisateur ou mot de passe incorrect' });
    }

    const user = rows[0];
    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(401).json({ error: 'Nom d\'utilisateur ou mot de passe incorrect' });
    }

    const accessToken = jwt.sign({ username: user.username, role: user.role }, process.env.ACCESS_TOKEN_SECRET, { expiresIn: '1h' });
    res.status(200).json({ accessToken, role: user.role });
  } catch (err) {
    console.error('Erreur lors de la connexion:', err);
    res.status(500).json({ error: 'Erreur interne du serveur' });
  }
});

// Route pour récupérer tous les utilisateurs
app.get('/users', authenticateToken, isAdmin, async (req, res) => {
  try {
    const [rows] = await db.query('SELECT id, username, role FROM users');
    res.status(200).json(rows);
  } catch (err) {
    console.error('Erreur lors de la récupération des utilisateurs :', err);
    res.status(500).json({ error: 'Erreur lors de la récupération des utilisateurs' });
  }
});



// Route pour ajouter un utilisateur
app.post('/users', authenticateToken, isAdmin, async (req, res) => {
  const { username, password, role } = req.body;

  if (!username || !password || !role) {
    return res.status(400).json({ error: 'Username, mot de passe et rôle sont requis' });
  }

  try {
    const hash = await bcrypt.hash(password, 10);
    const [result] = await db.query('INSERT INTO users (username, password, role) VALUES (?, ?, ?)', [username, hash, role]);
    res.status(201).json({ id: result.insertId, username, role });
  } catch (err) {
    console.error('Erreur lors de l\'ajout de l\'utilisateur:', err);
    res.status(500).json({ error: 'Erreur lors de l\'ajout de l\'utilisateur' });
  }
});


// Route pour mettre à jour un utilisateur
app.put('/users/:id', authenticateToken, isAdmin, async (req, res) => {
  const { id } = req.params;
  const { username, password, role } = req.body;

  const query = password ? 
    'UPDATE users SET username = ?, password = ?, role = ? WHERE id = ?' :
    'UPDATE users SET username = ?, role = ? WHERE id = ?';

  const params = password ? [username, await bcrypt.hash(password, 10), role, id] : [username, role, id];

  try {
    await db.query(query, params);
    res.status(200).json({ id, username, role });
  } catch (err) {
    console.error('Erreur lors de la mise à jour de l\'utilisateur:', err);
    res.status(500).json({ error: 'Erreur lors de la mise à jour de l\'utilisateur' });
  }
});


// Route pour supprimer un utilisateur
app.delete('/users/:id', authenticateToken, isAdmin, async (req, res) => {
  const { id } = req.params;
  try {
    await db.query('DELETE FROM users WHERE id = ?', [id]);
    res.status(204).end();
  } catch (err) {
    console.error('Erreur lors de la suppression de l\'utilisateur:', err);
    res.status(500).json({ error: 'Erreur lors de la suppression de l\'utilisateur' });
  }
});

app.get('/check-users', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT COUNT(*) as userCount FROM users');
    const userCount = rows[0].userCount;

    res.json({ isEmpty: userCount === 0 });
  } catch (error) {
    console.error('Erreur serveur:', error);
    res.status(500).json({ error: 'Erreur de serveur' });
  }
});




// Route pour vérifier le nombre d'utilisateurs
// app.get('/check-users', authenticateToken, isAdmin, async (req, res) => {
//   try {
//     const [rows] = await db.query('SELECT COUNT(*) as count FROM users');
//     const userCount = rows[0].count;
//     res.status(200).json({ isEmpty: userCount === 0 });
//   } catch (err) {
//     console.error('Erreur lors de la vérification des utilisateurs:', err);
//     res.status(500).json({ error: 'Erreur lors de la vérification des utilisateurs' });
//   }
// });

// Route pour récupérer toutes les caisses mères
app.get('/caisses-mere', authenticateToken, async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM caisses_mere');
    res.status(200).json(rows);
  } catch (err) {
    console.error('Erreur lors de la récupération des caisses mères :', err);
    res.status(500).json({ error: 'Erreur lors de la récupération des caisses mères' });
  }
});

app.get('/caisses-mere/:id', authenticateToken, (req, res) => {
  const id = req.params.id;
  db.query('SELECT * FROM caisses_mere WHERE id = ?', [id], (err, results) => {
    if (err) throw err;
    res.json(results[0]);
  });
});

// Route pour ajouter une caisse mère
app.post('/caisses-mere', authenticateToken, isAdmin, async (req, res) => {
  const { nom, solde_initial } = req.body;

  if (!nom || solde_initial === undefined) {
    return res.status(400).json({ error: 'Le nom et le solde initial sont requis.' });
  }

  try {
    const [result] = await db.query('INSERT INTO caisses_mere (nom, solde_initial) VALUES (?, ?)', [nom, solde_initial]);
    res.status(201).json({ id: result.insertId, nom, solde_initial });
  } catch (err) {
    console.error('Erreur lors de l\'ajout de la caisse mère:', err);
    res.status(500).json({ error: 'Erreur lors de l\'ajout de la caisse mère' });
  }
});

// Route pour mettre à jour une caisse mère
app.put('/caisses-mere/:id', authenticateToken, isAdmin, async (req, res) => {
  const { id } = req.params;
  const { nom, solde_initial } = req.body;

  if (!nom || solde_initial === undefined) {
    return res.status(400).json({ error: 'Le nom et le solde initial sont requis.' });
  }

  try {
    await db.query('UPDATE caisses_mere SET nom = ?, solde_initial = ? WHERE id = ?', [nom, solde_initial, id]);
    res.status(200).json({ message: 'Caisse mère mise à jour avec succès.' });
  } catch (err) {
    console.error('Erreur lors de la mise à jour de la caisse mère:', err);
    res.status(500).json({ error: 'Erreur lors de la mise à jour de la caisse mère' });
  }
});

// Route pour supprimer une caisse mère
app.delete('/caisses-mere/:id', authenticateToken, isAdmin, async (req, res) => {
  const { id } = req.params;

  try {
    await db.query('DELETE FROM caisses_mere WHERE id = ?', [id]);
    res.status(200).json({ message: 'Caisse mère supprimée avec succès.' });
  } catch (err) {
    console.error('Erreur lors de la suppression de la caisse mère:', err);
    res.status(500).json({ error: 'Erreur lors de la suppression de la caisse mère' });
  }
});

// Route pour récupérer toutes les caisses filles
app.get('/caisses-filles', authenticateToken, async (req, res) => {
  try {
    const connection = await getDbConnection();
    const [rows] = await connection.query('SELECT * FROM caisses_filles');
    connection.end();
    res.status(200).json(rows);
  } catch (err) {
    console.error('Erreur lors de la récupération des caisses filles :', err);
    res.status(500).json({ error: 'Erreur lors de la récupération des caisses filles', details: err.message });
  }
});



// Route pour ajouter une caisse fille
app.post('/caisses-filles', authenticateToken, isAdmin, async (req, res) => {
  const { nom, nom_caisse_mere, solde } = req.body;

  if (!nom || !nom_caisse_mere || solde === undefined) {
    return res.status(400).json({ error: 'Le nom, le nom de la caisse mère, et le solde sont requis.' });
  }

  try {
    const connection = await getDbConnection();
    const [result] = await connection.query(
      'INSERT INTO caisses_filles (nom, nom_caisse_mere, solde) VALUES (?, ?, ?)', 
      [nom, nom_caisse_mere, solde]
    );
    connection.end();
    res.status(201).json({ id: result.insertId, nom, nom_caisse_mere, solde });
  } catch (err) {
    console.error('Erreur lors de l\'ajout de la caisse fille :', err.message);
    res.status(500).json({ error: 'Erreur lors de l\'ajout de la caisse fille', details: err.message });
  }
});

// Route pour mettre à jour une caisse fille
app.put('/caisses-filles/:id', authenticateToken, isAdmin, async (req, res) => {
  const { id } = req.params;
  const { nom, nom_caisse_mere, solde } = req.body;

  if (!nom || !nom_caisse_mere || solde === undefined) {
    return res.status(400).json({ error: 'Le nom, le nom de la caisse mère et le solde sont requis.' });
  }

  try {
    const connection = await getDbConnection();
    await connection.query(
      'UPDATE caisses_filles SET nom = ?, nom_caisse_mere = ?, solde = ? WHERE id = ?',
      [nom, nom_caisse_mere, solde, id]
    );
    connection.end();
    res.status(200).json({ message: 'Caisse fille mise à jour avec succès.' });
  } catch (err) {
    console.error('Erreur lors de la mise à jour de la caisse fille :', err.message);
    res.status(500).json({ error: 'Erreur lors de la mise à jour de la caisse fille' });
  }
});

// Route pour supprimer une caisse fille
app.delete('/caisses-filles/:id', authenticateToken, isAdmin, async (req, res) => {
  const { id } = req.params;

  try {
    const connection = await getDbConnection();
    await connection.query('DELETE FROM caisses_filles WHERE id = ?', [id]);
    connection.end();
    res.status(200).json({ message: 'Caisse fille supprimée avec succès.' });
  } catch (err) {
    console.error('Erreur lors de la suppression de la caisse fille :', err.message);
    res.status(500).json({ error: 'Erreur lors de la suppression de la caisse fille' });
  }
});



// Route pour l'ouverture de la caisse
app.post('/ouverture-caisse', authenticateToken, (req, res) => {
  console.log('Requête reçue pour /ouverture-caisse');
  console.log('Corps de la requête:', req.body);

  const { caisseId, montantInitial } = req.body;
  
  if (!caisseId || montantInitial === undefined) {
    return res.status(400).json({ error: 'ID de caisse et montant initial sont requis' });
  }

  db.query('INSERT INTO caisses (id, montant_initial) VALUES (?, ?)', [caisseId, montantInitial], (err, result) => {
    if (err) {
      console.error('Erreur lors de l\'ouverture de la caisse:', err);
      return res.status(500).json({ error: 'Erreur lors de l\'ouverture de la caisse' });
    }
    res.status(200).json({ message: 'Caisse ouverte avec succès', caisseId });
  });
});

// Route pour vérifier l'état de la caisse
app.get('/etat-caisse/:id', authenticateToken, (req, res) => {
  const { id } = req.params;

  db.query('SELECT * FROM caisses WHERE id = ?', [id], (err, rows) => {
    if (err) {
      console.error('Erreur lors de la vérification de l\'état de la caisse:', err);
      return res.status(500).json({ error: 'Erreur lors de la vérification de l\'état de la caisse' });
    }
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Caisse non trouvée' });
    }
    res.status(200).json(rows[0]);
  });
});

// Route pour récupérer les transactions d'une caisse
app.get('/transactions/:id', authenticateToken, (req, res) => {
  const { id } = req.params;

  db.query('SELECT * FROM transactions WHERE caisse_id = ?', [id], (err, rows) => {
    if (err) {
      console.error('Erreur lors de la récupération des transactions:', err);
      return res.status(500).json({ error: 'Erreur lors de la récupération des transactions' });
    }
    res.status(200).json(rows);
  });
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
 