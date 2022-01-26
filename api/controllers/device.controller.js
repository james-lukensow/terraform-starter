const APIError = require('../utils/APIError');
const { generateToken } = require('../utils/jwt');
const { logger } = require('../utils/logger');

const registerDevice = async function (req, res, next) {
  try {
    const { body } = req;

    const { token } = generateToken({ body });

    res.json({
      token,
    });
  } catch (err) {
    logger.error({ err }, 'Err generating token');
    const error = new APIError('Error registering device', 400);
    return next(error);
  }
};

module.exports = {
  registerDevice,
};
