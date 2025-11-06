const express = require('express');
const router = express.Router();
const reservationController = require('../controllers/reservation.controller');
const auth = require('../middlewares/auth');

/**
 * @swagger
 * /api/reservations:
 *   post:
 *     summary: Créer une nouvelle réservation
 *     tags: [Reservations]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - reservation_date
 *               - reservation_time
 *               - guests
 *             properties:
 *               reservation_date:
 *                 type: string
 *                 format: date
 *                 example: "2025-11-15"
 *               reservation_time:
 *                 type: string
 *                 format: time
 *                 example: "19:00:00"
 *               guests:
 *                 type: integer
 *                 minimum: 1
 *                 example: 4
 *               notes:
 *                 type: string
 *                 example: "Fenêtre si possible"
 *               place_id:
 *                 type: integer
 *                 example: 1
 *     responses:
 *       201:
 *         description: Réservation créée avec succès
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                 reservationId:
 *                   type: integer
 *       400:
 *         $ref: '#/components/responses/ValidationError'
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 *       500:
 *         $ref: '#/components/responses/ServerError'
 *
 *   get:
 *     summary: Liste des réservations
 *     tags: [Reservations]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: place_id
 *         schema:
 *           type: integer
 *         description: Filtrer par lieu/branche
 *     responses:
 *       200:
 *         description: Liste des réservations
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Reservation'
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 *       500:
 *         $ref: '#/components/responses/ServerError'
 */
router.post('/', auth, reservationController.createReservation);
router.get('/', auth, reservationController.listReservations);

/**
 * @swagger
 * /api/reservations/{id}:
 *   put:
 *     summary: Modifier une réservation
 *     tags: [Reservations]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID de la réservation
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               reservation_date:
 *                 type: string
 *                 format: date
 *               reservation_time:
 *                 type: string
 *                 format: time
 *               guests:
 *                 type: integer
 *               notes:
 *                 type: string
 *     responses:
 *       200:
 *         description: Réservation modifiée avec succès
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 *       404:
 *         $ref: '#/components/responses/NotFoundError'
 *       500:
 *         $ref: '#/components/responses/ServerError'
 *
 *   delete:
 *     summary: Annuler une réservation
 *     tags: [Reservations]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID de la réservation
 *     responses:
 *       200:
 *         description: Réservation annulée avec succès
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 *       404:
 *         $ref: '#/components/responses/NotFoundError'
 *       500:
 *         $ref: '#/components/responses/ServerError'
 */
router.put('/:id', auth, reservationController.updateReservation);
router.delete('/:id', auth, reservationController.cancelReservation);

/**
 * @swagger
 * /api/reservations/{id}/status:
 *   patch:
 *     summary: Valider ou refuser une réservation (Hôte/Admin uniquement)
 *     tags: [Reservations]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID de la réservation
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - status
 *             properties:
 *               status:
 *                 type: string
 *                 enum: [confirmed, rejected, cancelled]
 *                 example: confirmed
 *     responses:
 *       200:
 *         description: Statut mis à jour avec succès
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                 reservationId:
 *                   type: integer
 *                 oldStatus:
 *                   type: string
 *                 newStatus:
 *                   type: string
 *       400:
 *         $ref: '#/components/responses/ValidationError'
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 *       403:
 *         $ref: '#/components/responses/ForbiddenError'
 *       404:
 *         $ref: '#/components/responses/NotFoundError'
 *       500:
 *         $ref: '#/components/responses/ServerError'
 */
router.patch('/:id/status', auth, reservationController.patchStatus);

module.exports = router;

