const express = require('express');
const router = express.Router();
const menuController = require('../controllers/menu.controller');
const auth = require('../middlewares/auth');

/**
 * @swagger
 * /api/menu:
 *   get:
 *     summary: Obtenir la liste du menu (plats disponibles uniquement)
 *     tags: [Menu]
 *     responses:
 *       200:
 *         description: Liste des plats disponibles
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/MenuItem'
 *       500:
 *         $ref: '#/components/responses/ServerError'
 *
 *   post:
 *     summary: Créer un nouveau plat (Host/Admin uniquement)
 *     tags: [Menu]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - price
 *               - category
 *             properties:
 *               name:
 *                 type: string
 *                 example: Salade César
 *               description:
 *                 type: string
 *                 example: Salade verte avec poulet grillé et parmesan
 *               price:
 *                 type: number
 *                 format: decimal
 *                 example: 12.50
 *               category:
 *                 type: string
 *                 enum: [starter, main, dessert, drink]
 *                 example: starter
 *               image_url:
 *                 type: string
 *                 format: uri
 *                 example: https://example.com/images/cesar.jpg
 *               available:
 *                 type: boolean
 *                 example: true
 *     responses:
 *       201:
 *         description: Plat créé avec succès
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                 menuItemId:
 *                   type: integer
 *       400:
 *         $ref: '#/components/responses/ValidationError'
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 *       403:
 *         $ref: '#/components/responses/ForbiddenError'
 *       500:
 *         $ref: '#/components/responses/ServerError'
 */
router.get('/', menuController.getMenu);
router.post('/', auth, menuController.createMenuItem);

/**
 * @swagger
 * /api/menu/all:
 *   get:
 *     summary: Obtenir tous les plats (disponibles et indisponibles) - Admin/Host
 *     tags: [Menu]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Liste complète des plats
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/MenuItem'
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 *       500:
 *         $ref: '#/components/responses/ServerError'
 */
router.get('/all', menuController.getAllMenuItems);

/**
 * @swagger
 * /api/menu/{id}:
 *   get:
 *     summary: Obtenir les détails d'un plat
 *     tags: [Menu]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID du plat
 *     responses:
 *       200:
 *         description: Détails du plat
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/MenuItem'
 *       404:
 *         $ref: '#/components/responses/NotFoundError'
 *       500:
 *         $ref: '#/components/responses/ServerError'
 *
 *   put:
 *     summary: Modifier un plat (Host/Admin uniquement)
 *     tags: [Menu]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID du plat
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               description:
 *                 type: string
 *               price:
 *                 type: number
 *               category:
 *                 type: string
 *                 enum: [starter, main, dessert, drink]
 *               image_url:
 *                 type: string
 *               available:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Plat mis à jour avec succès
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
 *
 *   delete:
 *     summary: Supprimer un plat (Admin uniquement)
 *     tags: [Menu]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID du plat
 *     responses:
 *       200:
 *         description: Plat supprimé avec succès
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 *       403:
 *         $ref: '#/components/responses/ForbiddenError'
 *       404:
 *         $ref: '#/components/responses/NotFoundError'
 *       500:
 *         $ref: '#/components/responses/ServerError'
 */
router.get('/:id', menuController.getMenuItem);
router.put('/:id', auth, menuController.updateMenuItem);
router.delete('/:id', auth, menuController.deleteMenuItem);

/**
 * @swagger
 * /api/menu/{id}/availability:
 *   patch:
 *     summary: Activer/Désactiver la disponibilité d'un plat (Host/Admin)
 *     tags: [Menu]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID du plat
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - available
 *             properties:
 *               available:
 *                 type: boolean
 *                 example: false
 *     responses:
 *       200:
 *         description: Disponibilité mise à jour
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                 available:
 *                   type: boolean
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
router.patch('/:id/availability', auth, menuController.toggleAvailability);

module.exports = router;


