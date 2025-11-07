/**
 * Service de notification pour les clients
 * Utilise Nodemailer avec Gmail SMTP pour envoyer des emails
 */

const nodemailer = require('nodemailer');
const dotenv = require('dotenv');

dotenv.config();

// Configuration du transporteur SMTP Gmail
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_APP_PASSWORD
  }
});

// Vérifier la configuration au démarrage
transporter.verify((error, success) => {
  if (error) {
    console.error('❌ Email configuration error:', error.message);
    console.log('💡 Assurez-vous que EMAIL_USER et EMAIL_APP_PASSWORD sont définis dans .env');
  } else {
    console.log('✅ Email service ready - Server is ready to send emails');
  }
});

/**
 * Fonction utilitaire pour obtenir l'email de l'utilisateur
 */
async function getUserEmail(userId) {
  try {
    const { getConnection } = require('../db');
    const connection = await getConnection();
    const [users] = await connection.execute('SELECT email, name FROM users WHERE id = ?', [userId]);
    await connection.end();
    
    if (users.length > 0) {
      return { email: users[0].email, name: users[0].name };
    }
    return null;
  } catch (error) {
    console.error('Error fetching user email:', error);
    return null;
  }
}

/**
 * Envoie une notification de changement de statut de réservation
 * @param {number} userId - ID de l'utilisateur à notifier
 * @param {number} reservationId - ID de la réservation
 * @param {string} oldStatus - Ancien statut
 * @param {string} newStatus - Nouveau statut
 */
exports.sendStatusUpdate = async (userId, reservationId, oldStatus, newStatus) => {
  try {
    const user = await getUserEmail(userId);
    
    if (!user || !user.email) {
      console.log(`⚠️  No email found for user ${userId}`);
      return;
    }
    
    const statusMessages = {
      confirmed: {
        subject: '✅ Réservation Confirmée !',
        text: `Bonjour ${user.name},\n\nVotre réservation #${reservationId} a été confirmée avec succès.\n\nMerci de votre confiance !\n\nÀ bientôt,\nL'équipe du Restaurant`,
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f9f9f9;">
            <div style="background-color: #4CAF50; color: white; padding: 20px; text-align: center; border-radius: 5px 5px 0 0;">
              <h1 style="margin: 0;">✅ Réservation Confirmée</h1>
            </div>
            <div style="background-color: white; padding: 30px; border-radius: 0 0 5px 5px;">
              <p style="font-size: 16px;">Bonjour <strong>${user.name}</strong>,</p>
              <p style="font-size: 16px;">Nous avons le plaisir de vous informer que votre réservation <strong>#${reservationId}</strong> a été <span style="color: #4CAF50; font-weight: bold;">confirmée avec succès</span>.</p>
              <p style="font-size: 14px; color: #666;">Nous avons hâte de vous accueillir dans notre restaurant !</p>
              <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
              <p style="font-size: 14px; color: #999;">À bientôt,<br><strong>L'équipe du Restaurant</strong></p>
            </div>
          </div>
        `
      },
      rejected: {
        subject: '❌ Réservation Refusée',
        text: `Bonjour ${user.name},\n\nNous sommes désolés de vous informer que votre réservation #${reservationId} a été refusée.\n\nRaison possible: Capacité maximale atteinte pour ce créneau.\n\nNous vous invitons à choisir un autre créneau horaire.\n\nCordialement,\nL'équipe du Restaurant`,
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f9f9f9;">
            <div style="background-color: #f44336; color: white; padding: 20px; text-align: center; border-radius: 5px 5px 0 0;">
              <h1 style="margin: 0;">❌ Réservation Refusée</h1>
            </div>
            <div style="background-color: white; padding: 30px; border-radius: 0 0 5px 5px;">
              <p style="font-size: 16px;">Bonjour <strong>${user.name}</strong>,</p>
              <p style="font-size: 16px;">Nous sommes désolés de vous informer que votre réservation <strong>#${reservationId}</strong> a été <span style="color: #f44336; font-weight: bold;">refusée</span>.</p>
              <p style="font-size: 14px; color: #666;">Raison possible: Capacité maximale atteinte pour ce créneau.</p>
              <p style="font-size: 14px; color: #666;">Nous vous invitons à choisir un autre créneau horaire.</p>
              <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
              <p style="font-size: 14px; color: #999;">Cordialement,<br><strong>L'équipe du Restaurant</strong></p>
            </div>
          </div>
        `
      },
      cancelled: {
        subject: '🚫 Réservation Annulée',
        text: `Bonjour ${user.name},\n\nVotre réservation #${reservationId} a été annulée.\n\nSi vous n'êtes pas à l'origine de cette annulation, veuillez nous contacter.\n\nCordialement,\nL'équipe du Restaurant`,
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f9f9f9;">
            <div style="background-color: #FF9800; color: white; padding: 20px; text-align: center; border-radius: 5px 5px 0 0;">
              <h1 style="margin: 0;">🚫 Réservation Annulée</h1>
            </div>
            <div style="background-color: white; padding: 30px; border-radius: 0 0 5px 5px;">
              <p style="font-size: 16px;">Bonjour <strong>${user.name}</strong>,</p>
              <p style="font-size: 16px;">Votre réservation <strong>#${reservationId}</strong> a été <span style="color: #FF9800; font-weight: bold;">annulée</span>.</p>
              <p style="font-size: 14px; color: #666;">Si vous n'êtes pas à l'origine de cette annulation, veuillez nous contacter.</p>
              <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
              <p style="font-size: 14px; color: #999;">Cordialement,<br><strong>L'équipe du Restaurant</strong></p>
            </div>
          </div>
        `
      }
    };
    
    const emailContent = statusMessages[newStatus];
    
    if (!emailContent) {
      console.log(`⚠️  No email template for status: ${newStatus}`);
      return;
    }
    
    const mailOptions = {
      from: `"Restaurant Reservation" <${process.env.EMAIL_USER}>`,
      to: user.email,
      subject: emailContent.subject,
      text: emailContent.text,
      html: emailContent.html
    };
    
    const info = await transporter.sendMail(mailOptions);
    
    console.log('✅ Email sent successfully:', {
      messageId: info.messageId,
      to: user.email,
      subject: emailContent.subject,
      reservationId,
      newStatus
    });
    
  } catch (error) {
    console.error('❌ Error sending email:', error.message);
  }
};

/**
 * Notifie les hôtes d'une nouvelle réservation
 * @param {number} reservationId - ID de la réservation
 * @param {object} reservationDetails - Détails de la réservation
 */
exports.notifyNewReservation = async (reservationId, reservationDetails) => {
  try {
    // Récupérer tous les utilisateurs avec le rôle 'host' ou 'admin'
    const { getConnection } = require('../db');
    const connection = await getConnection();
    const [hosts] = await connection.execute(
      'SELECT email, name FROM users WHERE role IN (?, ?)',
      ['host', 'admin']
    );
    await connection.end();
    
    if (hosts.length === 0) {
      console.log('⚠️  No hosts found to notify');
      return;
    }
    
    const { userId, date, timeSlot, partySize, placeName } = reservationDetails;
    
    // Récupérer les informations du client
    const client = await getUserEmail(userId);
    const clientName = client ? client.name : 'Client';
    const clientEmail = client ? client.email : 'Non disponible';
    
    const mailOptions = {
      from: `"Restaurant Reservation" <${process.env.EMAIL_USER}>`,
      to: hosts.map(h => h.email).join(', '),
      subject: '🔔 Nouvelle Réservation à Valider',
      text: `Nouvelle réservation reçue !\n\nRéservation #${reservationId}\nClient: ${clientName} (${clientEmail})\nDate: ${date}\nHeure: ${timeSlot}\nNombre de personnes: ${partySize}\nLieu: ${placeName || 'Non spécifié'}\n\nMerci de valider ou refuser cette réservation.`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f9f9f9;">
          <div style="background-color: #2196F3; color: white; padding: 20px; text-align: center; border-radius: 5px 5px 0 0;">
            <h1 style="margin: 0;">🔔 Nouvelle Réservation</h1>
          </div>
          <div style="background-color: white; padding: 30px; border-radius: 0 0 5px 5px;">
            <p style="font-size: 16px;">Une nouvelle réservation nécessite votre attention !</p>
            <div style="background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin: 20px 0;">
              <p style="margin: 5px 0;"><strong>Réservation:</strong> #${reservationId}</p>
              <p style="margin: 5px 0;"><strong>Client:</strong> ${clientName}</p>
              <p style="margin: 5px 0;"><strong>Email:</strong> ${clientEmail}</p>
              <p style="margin: 5px 0;"><strong>Date:</strong> ${date}</p>
              <p style="margin: 5px 0;"><strong>Heure:</strong> ${timeSlot}</p>
              <p style="margin: 5px 0;"><strong>Nombre de personnes:</strong> ${partySize}</p>
              ${placeName ? `<p style="margin: 5px 0;"><strong>Lieu:</strong> ${placeName}</p>` : ''}
            </div>
            <p style="font-size: 14px; color: #666;">Merci de valider ou refuser cette réservation via l'interface d'administration.</p>
            <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
            <p style="font-size: 14px; color: #999;">Système de Réservation du Restaurant</p>
          </div>
        </div>
      `
    };
    
    const info = await transporter.sendMail(mailOptions);
    
    console.log('✅ Host notification sent successfully:', {
      messageId: info.messageId,
      recipients: hosts.length,
      reservationId
    });
    
  } catch (error) {
    console.error('❌ Error notifying hosts:', error.message);
  }
};

/**
 * Envoie un rappel de réservation
 * @param {number} userId - ID de l'utilisateur
 * @param {number} reservationId - ID de la réservation
 * @param {string} reminderTime - Heure du rappel (ex: '1 hour before')
 */
exports.sendReservationReminder = async (userId, reservationId, reservationDetails) => {
  try {
    const user = await getUserEmail(userId);
    
    if (!user || !user.email) {
      console.log(`⚠️  No email found for user ${userId}`);
      return;
    }
    
    const { date, timeSlot, partySize, placeName, placeAddress } = reservationDetails;
    
    const mailOptions = {
      from: `"Restaurant Reservation" <${process.env.EMAIL_USER}>`,
      to: user.email,
      subject: '⏰ Rappel de Réservation - Demain !',
      text: `Bonjour ${user.name},\n\nCeci est un rappel pour votre réservation demain.\n\nRéservation #${reservationId}\nDate: ${date}\nHeure: ${timeSlot}\nNombre de personnes: ${partySize}\nLieu: ${placeName || 'Restaurant'}\n${placeAddress ? `Adresse: ${placeAddress}\n` : ''}\nÀ demain !\n\nL'équipe du Restaurant`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f9f9f9;">
          <div style="background-color: #FF9800; color: white; padding: 20px; text-align: center; border-radius: 5px 5px 0 0;">
            <h1 style="margin: 0;">⏰ Rappel de Réservation</h1>
          </div>
          <div style="background-color: white; padding: 30px; border-radius: 0 0 5px 5px;">
            <p style="font-size: 16px;">Bonjour <strong>${user.name}</strong>,</p>
            <p style="font-size: 16px;">Nous vous rappelons votre réservation pour <strong>demain</strong> !</p>
            <div style="background-color: #fff3cd; padding: 15px; border-left: 4px solid #FF9800; margin: 20px 0;">
              <p style="margin: 5px 0;"><strong>Réservation:</strong> #${reservationId}</p>
              <p style="margin: 5px 0;"><strong>Date:</strong> ${date}</p>
              <p style="margin: 5px 0;"><strong>Heure:</strong> ${timeSlot}</p>
              <p style="margin: 5px 0;"><strong>Nombre de personnes:</strong> ${partySize}</p>
              ${placeName ? `<p style="margin: 5px 0;"><strong>Lieu:</strong> ${placeName}</p>` : ''}
              ${placeAddress ? `<p style="margin: 5px 0;"><strong>Adresse:</strong> ${placeAddress}</p>` : ''}
            </div>
            <p style="font-size: 14px; color: #666;">Nous avons hâte de vous accueillir !</p>
            <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
            <p style="font-size: 14px; color: #999;">À bientôt,<br><strong>L'équipe du Restaurant</strong></p>
          </div>
        </div>
      `
    };
    
    const info = await transporter.sendMail(mailOptions);
    
    console.log('✅ Reminder email sent successfully:', {
      messageId: info.messageId,
      to: user.email,
      reservationId
    });
    
  } catch (error) {
    console.error('❌ Error sending reminder:', error.message);
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
