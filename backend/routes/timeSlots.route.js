const express = require('express');
const router = express.Router();
const timeSlotController = require('../controllers/timeSlot.controller');
const authMiddleware = require('../middlewares/auth');

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

/**
 * @swagger
 * /api/time-slots:
 *   post:
 *     summary: Créer un créneau horaire (admin seulement)
 *     tags: [Time Slots]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               slot_time:
 *                 type: string
 *                 format: time
 *                 example: "19:00:00"
 *               max_capacity:
 *                 type: integer
 *                 example: 50
 *     responses:
 *       201:
 *         description: Créneau créé
 *       400:
 *         $ref: '#/components/responses/ValidationError'
 *       403:
 *         description: Accès interdit
 *       500:
 *         $ref: '#/components/responses/ServerError'
 */
router.post('/', authMiddleware, timeSlotController.createTimeSlot);

/**
 * @swagger
 * /api/time-slots/{id}:
 *   delete:
 *     summary: Supprimer un créneau horaire (admin seulement)
 *     tags: [Time Slots]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Créneau supprimé
 *       403:
 *         description: Accès interdit
 *       404:
 *         description: Créneau non trouvé
 *       500:
 *         $ref: '#/components/responses/ServerError'
 */
router.delete('/:id', authMiddleware, timeSlotController.deleteTimeSlot);

module.exports = router;

