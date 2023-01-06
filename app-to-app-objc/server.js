'use strict';

const port = 3000;

const express = require('express')
const app = express();
app.use(express.json());

app.get('/voice/answer', (req, res) => {
  console.log('NCCO request:');
  const callee = JSON.parse(req.query.custom_data).callee;
  console.log(`  - caller: ${req.query.from_user}`);
  console.log(`  - callee: ${callee}`);
  console.log('---');
  res.json([ 
    { 
      "action": "talk", 
      "text": "Please wait while we connect you."
    },
    { 
      "action": "connect", 
      "endpoint": [ 
        { "type": "app", "user": callee } 
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

app.listen(port, () => {
  console.log(`Listening on port ${port}`)
});