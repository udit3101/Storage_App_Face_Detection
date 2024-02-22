const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const multer = require('multer');
const path = require('path');

const app = express();
const port = 3000;

app.use(bodyParser.json());

// MySQL Connection
const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'test',
});

connection.connect((err) => {
  if (err) {
    console.error('Error connecting to MySQL: ', err);
    throw err;
  }
  console.log('Connected to MySQL database');
});

// Set up storage for multer
const storage = multer.diskStorage({
  destination: 'uploads/', // Set your desired upload directory
  filename: (req, file, cb) => {
    const fileName = `${Date.now()}-${file.originalname}`;
    cb(null, fileName);
  },
});

const upload = multer();
app.post('/register', upload.single('profile_pic'), (req, res) => {
  const { name, email, phone, password, dob,avlspace } = req.body;
  const profilePicData = req.file ? req.file.buffer : null;

  // Insert user into the database with balance set to 0, profile picture data, and DOB
  const query =
    'INSERT INTO userlogin (name, email, phone, password, dob,avlspace, balance, profile_pic) VALUES (?, ?, ?, ?, ?, 0.5,0, ?)';
  connection.query(query, [name, email, phone, password, dob, profilePicData], (err, result) => {
    if (err) {
      console.error('Error registering user: ', err);
      res.status(500).json({ error: 'Internal Server Error' });
    } else {
      res.status(201).json({ message: 'User registered successfully' });
    }
  });
});





app.post('/login', (req, res) => {
  const { email, password } = req.body;

  // Check if the user with the provided email and password exists in the database
  const query = 'SELECT * FROM userlogin WHERE email = ? AND password = ?';
  connection.query(query, [email, password], (err, result) => {
    if (err) {
      console.error('Error during login: ', err);
      res.status(500).json({ error: 'Internal Server Error' });
    } else {
      if (result.length > 0) {
        // User exists, send a success message
        res.status(200).json({ message: 'Login successful' });
      } else {
        // User does not exist or incorrect credentials, send a failure message
        res.status(401).json({ error: 'Invalid credentials' });
      }
    }
  });
});




// API endpoint to get user balance by email
app.post('/getBalanceByEmail', (req, res) => {
  const { email } = req.body;

  const query = 'SELECT balance FROM userlogin WHERE email = ?';  // Replace "users" with your actual table name
  connection.query(query, [email], (err, result) => {
    if (err) {
      console.error('Error getting balance by email: ', err);
      res.status(500).json({ error: 'Internal Server Error' });
    } else {
      if (result.length === 0) {
        res.status(404).json({ error: 'User not found' });
      } else {
        const balance = result[0].balance;
        res.status(200).json({ balance });
      }
    }
  });
});










// API endpoint to update user balance after successful payment
app.post('/updateBalance', (req, res) => {
  const { email, amountPaid } = req.body;

  // Retrieve current balance from the database
  const getCurrentBalanceQuery = 'SELECT balance FROM userlogin WHERE email = ?';
  connection.query(getCurrentBalanceQuery, [email], (err, result) => {
    if (err) {
      console.error('Error getting current balance: ', err);
      res.status(500).json({ error: 'Internal Server Error' });
    } else {
      if (result.length === 0) {
        res.status(404).json({ error: 'User not found' });
      } else {
        const currentBalance = result[0].balance;

        // Update the balance in the database by adding the amount paid
        const updatedBalance = currentBalance + amountPaid;
        const updateBalanceQuery = 'UPDATE userlogin SET balance = ? WHERE email = ?';
        connection.query(updateBalanceQuery, [updatedBalance, email], (updateErr) => {
          if (updateErr) {
            console.error('Error updating balance: ', updateErr);
            res.status(500).json({ error: 'Internal Server Error' });
          } else {
            res.status(200).json({ success: true, updatedBalance });
          }
        });
      }
    }
  });
});








// API endpoint to deduct user balance
app.post('/deductBalance', (req, res) => {
  const { email, amount } = req.body;

  // Retrieve user balance from the database
  connection.query(
    'SELECT balance FROM userlogin WHERE email = ?',
    [email],
    (selectErr, results) => {
      if (selectErr) {
        console.error('Error selecting user balance: ', selectErr);
        return res.status(500).json({ error: 'Internal Server Error' });
      }

      if (results.length === 0) {
        return res.status(404).json({ error: 'User not found' });
      }

      const currentBalance = results[0].balance;

      if (currentBalance < amount) {
        return res.status(400).json({ error: 'Insufficient balance' });
      }

      // Deduct balance
      const updatedBalance = currentBalance - amount;

      // Update user balance in the database
      connection.query(
        'UPDATE userlogin SET balance = ? WHERE email = ?',
        [updatedBalance, email],
        (updateErr) => {
          if (updateErr) {
            console.error('Error updating user balance: ', updateErr);
            return res.status(500).json({ error: 'Internal Server Error' });
          }

          res.status(200).json({ updatedBalance });
        }
      );
    }
  );
});









app.get('/getUsername', (req, res) => {
  const { email } = req.query;

  const query = 'SELECT name FROM userlogin WHERE email = ?';
  connection.query(query, [email], (err, result) => {
    if (err) {
      console.error('Error retrieving name:', err);
      res.status(500).json({ error: 'Internal Server Error' });
    } else {
      if (result.length > 0) {
        const name = result[0].name;
        res.json({ name });
      } else {
        res.status(404).json({ error: 'name not found for the given email' });
      }
    }
  });
});









app.get('/getProfilePic/:email', (req, res) => {
  const email = req.params.email;

  // Query the database to get the profile picture data associated with the email
  const query = 'SELECT profile_pic FROM userlogin WHERE email = ?';
  connection.query(query, [email], (err, result) => {
    if (err) {
      console.error('Error fetching profile picture: ', err);
      res.status(500).json({ error: 'Internal Server Error' });
    } else {
      if (result.length > 0 && result[0].profile_pic) {
        const profilePicData = result[0].profile_pic;

        // Send the profile picture data as a response
        res.writeHead(200, { 'Content-Type': 'image/jpeg' }); // Adjust the content type based on your image type
        res.end(profilePicData);
      } else {
        res.status(404).json({ error: 'Profile picture not found' });
      }
    }
  });
});




// API endpoint to update avlspace in userlogin table
app.post('/updateAvlSpace', (req, res) => {
  const { email, purchasedSpace } = req.body;

  // Retrieve current avlspace from the database
  const getCurrentAvlSpaceQuery = 'SELECT avlspace FROM userlogin WHERE email = ?';
  connection.query(getCurrentAvlSpaceQuery, [email], (err, result) => {
    if (err) {
      console.error('Error getting current avlspace: ', err);
      res.status(500).json({ error: 'Internal Server Error' });
    } else {
      if (result.length === 0) {
        res.status(404).json({ error: 'User not found' });
      } else {
        const currentAvlSpace = result[0].avlspace;

        // Update avlspace in the database by adding the purchasedSpace
        const updatedAvlSpace = currentAvlSpace + purchasedSpace;
        const updateAvlSpaceQuery = 'UPDATE userlogin SET avlspace = ? WHERE email = ?';
        connection.query(updateAvlSpaceQuery, [updatedAvlSpace, email], (updateErr) => {
          if (updateErr) {
            console.error('Error updating avlspace: ', updateErr);
            res.status(500).json({ error: 'Internal Server Error' });
          } else {
            res.status(200).json({ success: true, updatedAvlSpace });
          }
        });
      }
    }
  });
});





// Add this route to get total size based on username
app.get('/totalsize', (req, res) => {
  const { username } = req.query;

  const query = 'SELECT totalsize FROM aqquirespace WHERE username = ?';
  connection.query(query, [username], (err, result) => {
    if (err) {
      console.error('Error retrieving total size:', err);
      res.status(500).json({ error: 'Internal Server Error' });
    } else {
      const totalSize = result.length > 0 ? result[0].totalsize/(1024 * 1024*1024) : 0;
      res.json({ totalSize });
    }
  });
});





app.get('/avlspace', (req, res) => {
  const { email } = req.query;

  const query = 'SELECT avlspace FROM userlogin WHERE email = ?';
  connection.query(query, [email], (err, result) => {
    if (err) {
      console.error('Error retrieving avlspace:', err);
      res.status(500).json({ error: 'Internal Server Error' });
    } else {
      const avlspace = result.length > 0 ? result[0].avlspace : "0.0";
      res.json({ avlspace });
    }
  });
});
















app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});

