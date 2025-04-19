/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();
const db = admin.firestore();

const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: "youremail@gmail.com", // use your Gmail
      pass: "your_app_password"    // use App Password (not regular password)
    }
  });   
  

exports.sendOtp = functions.https.onCall(async (data, context) => {
  const { email } = data;

  if (!email) {
    throw new functions.https.HttpsError("invalid-argument", "Email is required");
  }

  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  const expiresAt = Date.now() + 5 * 60 * 1000;

  await db.collection("email_otps").doc(email).set({ otp, expiresAt });

  await transporter.sendMail({
    from: "Aether App <youremail@gmail.com>",
    to: email,
    subject: "Your OTP for Aether",
    text: `Your OTP is: ${otp}. It will expire in 5 minutes.`
  });

  return { success: true };
});
