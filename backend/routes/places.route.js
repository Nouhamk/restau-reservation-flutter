const express = require('express');
const router = express.Router();
const placeController = require('../controllers/place.controller');
const auth = require('../middlewares/auth');

router.get('/', placeController.listPlaces);
router.get('/:id', placeController.getPlace);
router.post('/', auth, placeController.createPlace);
router.put('/:id', auth, placeController.updatePlace);
router.delete('/:id', auth, placeController.deletePlace);

module.exports = router;
