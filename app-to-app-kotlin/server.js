'use strict';

const subdomain = 'SUBDOMAIN';

const express = require('express')
const app = express();
app.use(express.json());

app.get('/voice/answer', (req, res) => {
  console.log('NCCO request:');
  console.log(`  - caller: ${req.query.from}`);
  console.log(`  - callee: ${req.query.to}`);
  console.log('---');
  var ncco = [{"action": "talk", "text": "No destination user - hanging up"}];
  var username = req.query.to;
  if (username) {
    ncco = [
      {
        "action": "talk",
        "text": "Connecting you to " + username
      },
      {
        "action": "connect",
        "endpoint": [
          {
            "type": "app",
            "user": username
          }
        ]
      }
    ]
  }
  res.json(ncco);
});

app.all('/voice/event', (req, res) => {
  console.log('EVENT:');
  console.dir(req.body);
  console.log('---');
  res.sendStatus(200);
});

if(subdomain == "SUBDOMAIN") {
  console.log('\n\t🚨🚨🚨 Please change the SUBDOMAIN value');
  return false;
}
app.listen(3000);

const localtunnel = require('localtunnel');
(async () => {
  const tunnel = await localtunnel({ 
      subdomain: subdomain, 
      port: 3000
    });
  console.log(`App available at: ${tunnel.url}`);
})();