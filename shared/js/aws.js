const https = require('https')
const AWS = require('aws-sdk')

const sslAgent = new https.Agent({
  keepAlive: true,
  maxSockets: 50, // same as aws-sdk
  rejectUnauthorized: true, // same as aws-sdk
})
sslAgent.setMaxListeners(0) // same as aws-sdk

AWS.config.update({
  httpOptions: {
    agent: sslAgent,
    timeout: 2000, // Defaults to two minutes: 120000
  }
})

module.exports = AWS