'use strict';
const express = require('express')
const app = express();
app.use(express.json());

app.get('/voice/answer', (req, res) => {
  console.log('NCCO request:');
  console.log(`  - callee: ${req.query.to}`);
  console.log('---');
  res.json([ 
    { 
      "action": "talk", 
      "text": "Please wait while we connect you."
    },
    { 
      "action": "connect", 
      "endpoint": [ 
        { "type": "phone", "number": req.query.to } 
      ]
    }
  ]);
});

app.all('/voice/event', (req, res) => {
  console.log('EVENT:');
  console.dir(req.body);
  console.log('---');
  res.sendStatus(200);
});

app.listen(3001);


const localtunnel = require('localtunnel');
(async () => {
  const tunnel = await localtunnel({ 
      // subdomain: 'SUBDOMAIN', 
      subdomain: 'paul-vonage',
      port: 3001
    });
  console.log(`App available at: ${tunnel.url}`);
})();
