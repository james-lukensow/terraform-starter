// set up the libraries
require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const httpStatus = require('http-status');
const helmet = require('helmet');
const { ValidationError } = require('express-validation');

const { logger } = require('./utils/logger');
const routes = require('./routes/index.route');
const APIError = require('./utils/APIError');
const app = express();

// parse body params and attache them to req.body
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.use(
  helmet({
    contentSecurityPolicy: false,
  }),
);

// Host API Docs
if (process.env.API_DOCS === 'true') {
  app.use('/apidoc', express.static('apidoc'));
}

app.use('/', routes);

const errHandler = (
  err,
  req, // eslint-disable-line no-unused-vars
  res,
) => {
  const response = {
    code: err.status,
    message: err.message || httpStatus[err.status],
    errors: err.errors,
    stack: err.stack,
  };

  if (process.env.NODE_ENV !== 'development') {
    delete response.stack;
  }

  if (response.errors.length === 0) {
    delete response.errors;
  }

  res.status(err.status);
  res.json(response);
};

// catch 404 and forward to error handler
app.use((req, res) => {
  const err = new APIError('Resource not found', httpStatus.NOT_FOUND);
  return errHandler(err, req, res);
});

app.use((err, req, res, next) => {
  let convertedError = err;

  if (err instanceof ValidationError) {
    return res.status(err.statusCode).json(err);
  } else if (!(err instanceof APIError)) {
    convertedError = new APIError(err.message, err.status);
  }

  return errHandler(convertedError, req, res);
});

app.use(errHandler);

// start listener
logger.info(`Starting listener on port ${process.env.API_PORT} ...`);
app.listen(process.env.API_PORT);
