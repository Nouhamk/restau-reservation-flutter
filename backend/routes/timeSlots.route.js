const express = require('express');
const router = express.Router();
const timeSlotController = require('../controllers/timeSlot.controller');

router.get('/', timeSlotController.listTimeSlots);
router.get('/availability', timeSlotController.checkAvailability);

module.exports = router;
