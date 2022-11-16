'use strict';

const vonageNumber = 'NUMBER';
const port = 3000;

const express = require('express')
const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/voice/answer', (req, res) => {
  console.log('NCCO request:');
  const callee = JSON.parse(req.query.custom_data).number
  console.log(`  - callee: ${callee}`);
  console.log('---');
  res.json([ 
    { 
      "action": "talk", 
      "text": "Please wait while we connect you."
    },
    { 
      "action": "connect",
      "from": vonageNumber,
      "endpoint": [ 
        { "type": "phone", "number": callee } 
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

if(vonageNumber == "NUMBER") {
  console.log('\n\t🚨🚨🚨 Please change the NUMBER value');
  return false;
}

app.listen(port, () => {
  console.log(`Listening on port ${port}`)
});