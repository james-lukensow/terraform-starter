const bunyan = require('bunyan');
const log = bunyan.createLogger({
  name: 'terraform-api',
  serializers: {
    err: bunyan.stdSerializers.err,
  },
});

module.exports = {
  logger: log,
};
