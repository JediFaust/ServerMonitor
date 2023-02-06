const axios = require("axios")
const mailer = require("nodemailer")
require("dotenv").config()

const urls = [ "http://fyi.ai", "http://localhost:8000/2" ]
const interval = 5 * 60 * 1000; // interval timestamp in minutes
const email = process.env.MAIL_TO 

const express = require('express')
const app = express()
const port = 8000

const { Sequelize, DataTypes } = require('sequelize')

const sequelize = new Sequelize({
    dialect: 'sqlite',
    storage: './database.sqlite'
});

async function checkConnection() {
try {
    await sequelize.authenticate();
    console.log('Connection has been established successfully.');
} catch (error) {
    console.error('Unable to connect to the database:', error);
}
}

checkConnection()

const Server = sequelize.define('server', {
    url: DataTypes.TEXT,
    status: DataTypes.INTEGER
})

// Get Query from Qt
app.get('/status/', async (_, res) => {
    const servers = await Server.findAll();
    res.send(servers)
})

app.listen(port)

let transporter = mailer.createTransport({
    service: "gmail",
    auth: {
        user: process.env.MAIL_LOGIN,
        pass: process.env.MAIL_PASS
    }
})

    setTimeout(delayedCheck, interval)

function saveStatus(serv) {
    serv.status = 1
    serv.save()
}

async function delayedCheck() {
    await sequelize.sync({ force: true })
    urls.forEach((url) => {
            let server = Server.create({ url: url, status: 0 })
            axios.get(url).then(async function(response) {
                    if (response.status >= 500) {
                        onServerUnavailable(url)
                    } else {
                        saveStatus(await server)
                    }
                }).catch(err => {
                    console.error(err)
                    onServerUnavailable(url)
                })
    })

    setTimeout(delayedCheck, interval)
}


function onServerUnavailable(url) {
    let mailOptions = {
        from: process.env.MAIL_LOGIN,
        to: email,
        subject: "ServerDown Report",
        text: "Server downed on URL: " + url
    }
    
    transporter.sendMail(mailOptions, (err, _) => {
        if (err) {
            console.log("Error sending an email report: " + err)
        } else {
            console.log("Email sent success!")
        }
    })
}