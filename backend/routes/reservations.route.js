const express = require('express');
const router = express.Router();
const reservationController = require('../controllers/reservation.controller');
const auth = require('../middlewares/auth');

router.post('/', auth, reservationController.createReservation);
router.get('/', auth, reservationController.listReservations);
router.put('/:id', auth, reservationController.updateReservation);
router.delete('/:id', auth, reservationController.cancelReservation);
router.patch('/:id/status', auth, reservationController.patchStatus);

module.exports = router;
