const express = require('express');
const multer = require('multer');
const cloudinary = require('cloudinary').v2;
const mysql = require('mysql2');

const app = express();
const upload = multer({ dest: 'uploads/' });

// Cloudinary configuration
cloudinary.config({
  cloud_name: 'dgbsx7rwm',
  api_key: '682895674479611',
  api_secret: 'XlU3smNi_blPNygEj8KWVo3DCjQ'
});

// MySQL configuration
const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'test'
});

connection.connect(err => {
  if (err) {
    console.error('Error connecting to MySQL: ' + err.stack);
    return;
  }
  console.log('Connected to MySQL as id ' + connection.threadId);
});

// Endpoint to upload image
app.post('/upload', upload.single('image'), (req, res) => {
  const { username } = req.body;
  const { path, size } = req.file; // Extract image size

  // Upload image to Cloudinary with a tag
  cloudinary.uploader.upload(path, { tags: [username, 'all'] }, (error, result) => {
      if (error) {
          console.error('Error uploading image to Cloudinary:', error);
          return res.status(500).json({ error: 'Failed to upload image' });
      }

      const imageUrl = result.secure_url;

      // Store image URL, username, and image size in MySQL
      const query = 'INSERT INTO images (username, url, image_size) VALUES (?, ?, ?)';
      connection.query(query, [username, imageUrl, size], (err, results) => {
          if (err) {
              console.error('Error storing image URL in MySQL:', err);
              return res.status(500).json({ error: 'Failed to store image URL' });
          }
          
          const acquireSpaceQuery = `
              INSERT INTO aqquireSpace (username, totalsize)
              VALUES (?, ?)
              ON DUPLICATE KEY UPDATE totalsize = totalsize + VALUES(totalsize)
          `;
          connection.query(acquireSpaceQuery, [username, size], (err) => {
              if (err) {
                  console.error('Error updating acquireSpace:', err);
                  return res.status(500).json({ error: 'Internal Server Error' });
              } else {
                  res.status(200).json({ imageUrl });
              }
          });
      });
  });
});





  app.post('/uploadSelfie', upload.single('image'), (req, res) => {
    const { username, person } = req.body;
    const { path, size } = req.file;

    // Upload image to Cloudinary
    cloudinary.uploader.upload(path, { tags: [username, 'selfies'] }, (error, result) => {
      if (error) {
          console.error('Error uploading image to Cloudinary:', error);
          return res.status(500).json({ error: 'Failed to upload image' });
      }

        const imageUrl = result.secure_url;

        // Store image URL, username, person, and size in MySQL
        const query = 'INSERT INTO selfies (username, url, person, size) VALUES (?, ?, ?, ?)';
        connection.query(query, [username, imageUrl, person, size], (err, results) => {
            if (err) {
                console.error('Error storing image data in MySQL:', err);
                return res.status(500).json({ error: 'Failed to store image data' });
            }

            // Update total size in aqquirespace table
            const acquireSpaceQuery = `
                INSERT INTO aqquirespace (username, totalsize)
                VALUES (?, ?)
                ON DUPLICATE KEY UPDATE totalsize = totalsize + VALUES(totalsize)
            `;
            connection.query(acquireSpaceQuery, [username, size], (err) => {
                if (err) {
                    console.error('Error updating aqquirespace:', err);
                    res.status(500).json({ error: 'Internal Server Error' });
                } else {
                    res.status(200).json({ imageUrl });
                }
            });
        });
    });
});

  
  



  app.get('/images/:username', (req, res) => {
    const username = req.params.username;
  
    // Query images by username
    const query = 'SELECT url FROM images WHERE username = ?';
    connection.query(query, [username], (err, results) => {
      if (err) {
        console.error('Error fetching images from MySQL:', err);
        return res.status(500).json({ error: 'Failed to fetch images' });
      }
  
      const imageUrls = results.map(result => result.url);
      res.status(200).json({ images: imageUrls });
    });
  });
  



  app.get('/images/:username/:person', (req, res) => {
    const username = req.params.username;
    const person = req.params.person;
  
    // Query images by username and person
    const query = 'SELECT url FROM selfies WHERE username = ? AND person = ?';
    connection.query(query, [username, person], (err, results) => {
      if (err) {
        console.error('Error fetching images from MySQL:', err);
        return res.status(500).json({ error: 'Failed to fetch images' });
      }
  
      const imageUrls = results.map(result => result.url);
      res.status(200).json({ images: imageUrls });
    });
  });
  


  // Define route to get unique persons by username
app.get('/unique_persons/:username', (req, res) => {
  const { username } = req.params;
  // Query to get unique persons associated with the provided username
  const sql = 'SELECT DISTINCT person FROM selfies WHERE username = ?';
  
  // Execute the query
  connection.query(sql, [username], (err, result) => {
    if (err) {
      console.error('Error executing MySQL query:', err);
      res.status(500).json({ error: 'Internal server error' });
      return;
    }
    // Extract the unique persons from the query result
    const uniquePersons = result.map(row => row.person);
    
    // Send the unique persons as JSON response
    res.json(uniquePersons);
  });
});






  
app.listen(9500, () => {
  console.log('Server is running on port 9500');
});
