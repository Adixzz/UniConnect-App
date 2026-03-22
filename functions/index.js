const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onCall } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
admin.initializeApp();

// triggers when a new document is added to notifications collection
exports.sendTimetableNotification = onDocumentCreated(
  "notifications/{notificationId}",
  async (event) => {
    const data = event.data.data();

    if (data.type !== "timetable_update") return null;

    try {
      const usersSnapshot = await admin.firestore()
        .collection("users")
        .where("role", "==", "student")
        .where("pathway", "==", data.pathway)
        .where("degree", "==", data.degree)
        .where("academicYear", "==", data.academicYear)
        .where("semester", "==", data.semester)
        .where("calendarYear", "==", data.calendarYear)
        .get();

      if (usersSnapshot.empty) {
        console.log("No matching students found");
        return null;
      }

      const tokens = [];
      usersSnapshot.forEach((doc) => {
        const token = doc.data().fcmToken;
        if (token) tokens.push(token);
      });

      if (tokens.length === 0) {
        console.log("No FCM tokens found");
        return null;
      }

      const message = {
        notification: {
          title: "Timetable Update 📅",
          body: data.message,
        },
        data: {
          type: "timetable_update",
          timetableId: data.timetableId,
        },
        tokens: tokens,
      };

      const response = await admin.messaging().sendEachForMulticast(message);
      console.log(`Successfully sent: ${response.successCount}`);
      console.log(`Failed: ${response.failureCount}`);
      return null;

    } catch (error) {
      console.error("Error:", error);
      return null;
    }
  }
);

// deletes a user from Firebase Auth when called from Flutter app
exports.deleteUser = onCall(async (request) => {
  const uid = request.data.uid;

  if (!uid) {
    const { HttpsError } = require("firebase-functions/v2/https");
    throw new HttpsError("invalid-argument", "UID is required");
  }

  try {
    await admin.auth().deleteUser(uid);
    return { success: true };
  } catch (error) {
    const { HttpsError } = require("firebase-functions/v2/https");
    throw new HttpsError("internal", error.message);
  }
});