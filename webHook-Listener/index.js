// webhook.js

const express = require('express');
const bodyParser = require('body-parser');
const { exec } = require('child_process');
const crypto = require('crypto');
const dotenv = require("dotenv");

dotenv.config();
const app = express();
const port = 3000;

// Replace this with your secret key for security
const SECRET = process.env.WEBHOOK_SECRET;
console.log(SECRET);

// Middleware to parse incoming JSON data
app.use(bodyParser.json());

// Function to verify the GitHub webhook signature
const verifySignature = (req, res, next) => {
    const signature = req.headers['x-hub-signature-256'];
    const payload = JSON.stringify(req.body);

    const hmac = crypto.createHmac('sha256', SECRET);
    const digest = `sha256=${hmac.update(payload).digest('hex')}`;

    if (signature !== digest) {
        return res.status(403).send('Invalid signature');
    }

    next();
};

// Webhook route for GitHub push events
app.post('/webhook', verifySignature, (req, res) => {
    console.log('Webhook received!');

    // Check if the webhook event is a push event
    if (req.body.ref === 'refs/heads/main') {
        console.log('Push event detected. Deploying...');

        // Run the deploy script
        exec('/var/www/Frontend-main-cc/deploy.sh', (error, stdout, stderr) => {
            if (error) {
                console.error(`Error executing deploy script: ${error}`);
                return res.status(500).send('Deployment failed');
            }
            if (stderr) {
                console.error(`stderr: ${stderr}`);
                return res.status(500).send('Deployment failed');
            }
            console.log(`stdout: ${stdout}`);
            res.status(200).send('Deployment successful');
        });
    } else {
        res.status(200).send('Push event not to main branch');
    }
});

// Start the server
app.listen(port, () => {
    console.log(`Webhook listener running at http://localhost:${port}`);
});
