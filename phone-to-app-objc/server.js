'use strict';

const port = 3000;

const express = require('express')
const app = express();

app.use(express.json());

app.get('/voice/answer', (req, res) => {
  console.log('NCCO request:');
  console.log(`  - caller: ${req.query.from}`);
  console.log('---');
  res.json([ 
    { 
      "action": "talk", 
      "text": "Please wait while we connect you."
    },
    { 
      "action": "connect", 
      "from": req.query.from,
      "endpoint": [ 
        { "type": "app", "user": "Alice" } 
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