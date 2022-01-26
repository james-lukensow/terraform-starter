const AWS = require('../../shared/js/aws.js')

module.exports.handle = async function (event, _, log) {
  console.log('Hello World!')
  console.log('AWS', AWS)

  return {
    success: true
  }
}