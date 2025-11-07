const express = require('express');
const router = express.Router();
const adminController = require('../controllers/admin.controller');
const auth = require('../middlewares/auth');

/**
 * @swagger
 * /api/admin/stats:
 *   get:
 *     summary: Récupérer les statistiques globales (Admin / Host)
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Statistiques système
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 restaurants:
 *                   type: integer
 *                 clients:
 *                   type: integer
 *                 hosts:
 *                   type: integer
 *                 reservations:
 *                   type: integer
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 *       403:
 *         $ref: '#/components/responses/ForbiddenError'
 *       500:
 *         $ref: '#/components/responses/ServerError'
 */
router.get('/stats', auth, adminController.getStats);

module.exports = router;
