//express App Setup
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(bodyParser.json());


app.get('/', (req, res) => {
    res.send ('Hi');
});

/*
app.get('/values/all', async(req, res)=> {
    const values = await pgClient.query('SELECT * from values');
    res.send(values.rows);
});
*/


app.listen(5000, err =>{
    console.log('Listening');
});
