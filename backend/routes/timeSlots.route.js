const express = require('express');
const router = express.Router();
const timeSlotController = require('../controllers/timeSlot.controller');

/**
 * @swagger
 * /api/time-slots:
 *   get:
 *     summary: Liste des créneaux horaires
 *     tags: [Time Slots]
 *     responses:
 *       200:
 *         description: Liste des créneaux disponibles
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/TimeSlot'
 *       500:
 *         $ref: '#/components/responses/ServerError'
 */
router.get('/', timeSlotController.listTimeSlots);

/**
 * @swagger
 * /api/time-slots/availability:
 *   get:
 *     summary: Vérifier la disponibilité pour un créneau
 *     tags: [Time Slots]
 *     parameters:
 *       - in: query
 *         name: date
 *         required: true
 *         schema:
 *           type: string
 *           format: date
 *         example: "2025-11-15"
 *         description: Date de la réservation (YYYY-MM-DD)
 *       - in: query
 *         name: time
 *         required: true
 *         schema:
 *           type: string
 *           format: time
 *         example: "19:00:00"
 *         description: Heure du créneau (HH:MM:SS)
 *       - in: query
 *         name: place_id
 *         schema:
 *           type: integer
 *         example: 1
 *         description: ID du lieu (optionnel)
 *     responses:
 *       200:
 *         description: Disponibilité du créneau
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 maxCapacity:
 *                   type: integer
 *                   example: 50
 *                 reserved:
 *                   type: integer
 *                   example: 20
 *                 available:
 *                   type: integer
 *                   example: 30
 *       400:
 *         $ref: '#/components/responses/ValidationError'
 *       500:
 *         $ref: '#/components/responses/ServerError'
 */
router.get('/availability', timeSlotController.checkAvailability);

module.exports = router;

