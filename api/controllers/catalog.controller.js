const APIError = require('../utils/APIError');
const {
  fetchFromMemcache,
  refreshMemcache,
  fetchProductFromMemcache,
  getQuantity,
  deleteCache,
} = require('../utils/catalog');
const { logger } = require('../utils/logger');

const getCatalog = async function (req, res, next) {
  try {
    let catalogData = await fetchFromMemcache();

    if (catalogData) {
      logger.info('Memcache hit! Returning data.');
      return res.json(catalogData);
    } else {
      const data = await refreshMemcache();

      if (data) {
        return res.json(data);
      }

      // No catalog data to return 😬
      const error = new APIError('Error fetching catalog data', 500);
      return next(error);
    }
  } catch (err) {
    logger.error({ err }, 'Err fetching catalog');
    const error = new APIError('Error fetching catalog', 500);
    return next(error);
  }
};

const getCatalogQuantities = async function (req, res, next) {
  try {
    const quantities = await getQuantity();
    res.json(quantities ? quantities : []);
  } catch (err) {
    logger.error({ err }, 'Err fetching catalog quantities');
    const error = new APIError('Error fetching catalog quantities', 500);
    return next(error);
  }
};

const deleteCatalog = async function (req, res, next) {
  try {
    await deleteCache();
    res.json({ status: 'deleted' });
  } catch (err) {
    logger.error({ err }, 'Err deleting catalog');
    const error = new APIError('Error deleting catalog', 500);
    return next(error);
  }
};

const getDynamicProductId = async function (req, res, next) {
  try {
    const {
      params: { productId },
    } = req;

    const product = await fetchProductFromMemcache({ productId });

    if (!product) {
      const error = new APIError('Resource not found', 404);
      return next(error);
    }

    res.status(204).send();
    // res.json({
    //   ...product,
    // });
  } catch (err) {
    logger.error({ err }, 'Err deleting catalog');
    const error = new APIError('Error fetching product by id', 500);
    return next(error);
  }
};

module.exports = {
  getCatalog,
  getCatalogQuantities,
  deleteCatalog,
  getDynamicProductId,
};
