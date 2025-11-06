const express = require('express');
const router = express.Router();
const placeController = require('../controllers/place.controller');
const auth = require('../middlewares/auth');

/**
 * @swagger
 * /api/places:
 *   get:
 *     summary: Liste de tous les lieux/branches
 *     tags: [Places]
 *     responses:
 *       200:
 *         description: Liste des lieux
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Place'
 *       500:
 *         $ref: '#/components/responses/ServerError'
 *
 *   post:
 *     summary: Créer un nouveau lieu (Admin uniquement)
 *     tags: [Places]
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
 *             properties:
 *               name:
 *                 type: string
 *                 example: Restaurant Centre-Ville
 *               address:
 *                 type: string
 *                 example: 123 Rue Principale, Paris
 *               phone:
 *                 type: string
 *                 example: "0123456789"
 *               capacity:
 *                 type: integer
 *                 example: 50
 *     responses:
 *       201:
 *         description: Lieu créé avec succès
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                 placeId:
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
router.get('/', placeController.listPlaces);
router.post('/', auth, placeController.createPlace);

/**
 * @swagger
 * /api/places/{id}:
 *   get:
 *     summary: Obtenir les détails d'un lieu
 *     tags: [Places]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID du lieu
 *     responses:
 *       200:
 *         description: Détails du lieu
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Place'
 *       404:
 *         $ref: '#/components/responses/NotFoundError'
 *       500:
 *         $ref: '#/components/responses/ServerError'
 *
 *   put:
 *     summary: Modifier un lieu (Admin uniquement)
 *     tags: [Places]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID du lieu
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               address:
 *                 type: string
 *               phone:
 *                 type: string
 *               capacity:
 *                 type: integer
 *     responses:
 *       200:
 *         description: Lieu mis à jour avec succès
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 *       403:
 *         $ref: '#/components/responses/ForbiddenError'
 *       500:
 *         $ref: '#/components/responses/ServerError'
 *
 *   delete:
 *     summary: Supprimer un lieu (Admin uniquement)
 *     tags: [Places]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID du lieu
 *     responses:
 *       200:
 *         description: Lieu supprimé avec succès
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 *       403:
 *         $ref: '#/components/responses/ForbiddenError'
 *       500:
 *         $ref: '#/components/responses/ServerError'
 */
router.get('/:id', placeController.getPlace);
router.put('/:id', auth, placeController.updatePlace);
router.delete('/:id', auth, placeController.deletePlace);

module.exports = router;

