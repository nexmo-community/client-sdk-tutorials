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
        "text": "Connecting you to Bob"
    },
    {
        "action": "connect",
        "endpoint": [
            {
                "type": "app",
                "user": "Bob"
            }
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

app.listen(3000);


const localtunnel = require('localtunnel');
(async () => {
  const tunnel = await localtunnel({ 
      subdomain: 'SUBDOMAIN', 
      port: 3000
    });
  console.log(`App available at: ${tunnel.url}`);
})();