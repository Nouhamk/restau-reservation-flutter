/**
 * Service de notification pour les clients
 * 
 * Pour implémenter Firebase Cloud Messaging (FCM):
 * 1. npm install firebase-admin
 * 2. Obtenir le fichier serviceAccountKey.json depuis Firebase Console
 * 3. Initialiser Firebase Admin SDK
 * 4. Stocker les FCM tokens des utilisateurs dans la DB
 * 5. Implémenter les fonctions ci-dessous
 */

// const admin = require('firebase-admin');
// const serviceAccount = require('../config/firebase-service-account.json');

// admin.initializeApp({
//   credential: admin.credential.cert(serviceAccount)
// });

/**
 * Envoie une notification de changement de statut de réservation
 * @param {number} userId - ID de l'utilisateur à notifier
 * @param {number} reservationId - ID de la réservation
 * @param {string} oldStatus - Ancien statut
 * @param {string} newStatus - Nouveau statut
 */
exports.sendStatusUpdate = async (userId, reservationId, oldStatus, newStatus) => {
  try {
    // TODO: Récupérer le FCM token de l'utilisateur depuis la DB
    // const userToken = await getUserFCMToken(userId);
    
    // if (!userToken) {
    //   console.log(`No FCM token found for user ${userId}`);
    //   return;
    // }
    
    const statusMessages = {
      confirmed: 'Votre réservation a été confirmée ! 🎉',
      rejected: 'Désolé, votre réservation a été refusée. 😔',
      cancelled: 'Votre réservation a été annulée.'
    };
    
    const message = {
      notification: {
        title: 'Mise à jour de réservation',
        body: statusMessages[newStatus] || 'Statut de votre réservation mis à jour'
      },
      data: {
        reservationId: reservationId.toString(),
        oldStatus,
        newStatus,
        type: 'reservation_status_update'
      }
      // token: userToken
    };
    
    // const response = await admin.messaging().send(message);
    // console.log('Notification sent successfully:', response);
    
    console.log(`[NOTIFICATION STUB] Would send to user ${userId}:`, message);
    
  } catch (error) {
    console.error('Error sending notification:', error);
  }
};

/**
 * Envoie une notification de nouvelle réservation au hôte
 * @param {number} reservationId - ID de la réservation
 * @param {object} reservationData - Données de la réservation
 */
exports.notifyNewReservation = async (reservationId, reservationData) => {
  try {
    // TODO: Récupérer les FCM tokens de tous les hôtes/admins
    
    const message = {
      notification: {
        title: 'Nouvelle réservation',
        body: `Nouvelle réservation pour ${reservationData.guests} personnes le ${reservationData.date}`
      },
      data: {
        reservationId: reservationId.toString(),
        type: 'new_reservation'
      }
    };
    
    console.log('[NOTIFICATION STUB] Would notify hosts:', message);
    
  } catch (error) {
    console.error('Error sending notification:', error);
  }
};

/**
 * Envoie une notification de rappel avant la réservation
 * @param {number} userId - ID de l'utilisateur
 * @param {number} reservationId - ID de la réservation
 * @param {string} reservationDate - Date de la réservation
 * @param {string} reservationTime - Heure de la réservation
 */
exports.sendReservationReminder = async (userId, reservationId, reservationDate, reservationTime) => {
  try {
    const message = {
      notification: {
        title: 'Rappel de réservation',
        body: `N'oubliez pas votre réservation aujourd'hui à ${reservationTime} ! 🍽️`
      },
      data: {
        reservationId: reservationId.toString(),
        type: 'reservation_reminder'
      }
    };
    
    console.log(`[NOTIFICATION STUB] Would send reminder to user ${userId}:`, message);
    
  } catch (error) {
    console.error('Error sending reminder:', error);
  }
};
