const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
exports.sendFcm = functions.https.onRequest(async (req, res) => {
  // functions.logger.info("Hello logs!", {structuredData: true});
  const message = {
    token:
      "daf_Ive9QZGUMBteqHLrhr:APA91bGPM0sE_E3bzplqyyaderqcqHotErpKx0-JO83Op1WoJ4_7RE-Hp9_sAP3-6iN_LJg1BW92LgLsVs286iMGq1v2aQY6kzwG7Iblv73C67cupl5XY0FRlimlNoK8QNwzysciBcEE",
    data: {
      title: req.body.title,
      body: req.body.body,
    },
    apns: {
      headers: {
        "apns-priority": "5",
        "apns-push-type": "background",
      },
      payload: {
        aps: {
          "content-available": 1,
        },
      },
    },
  };

  admin
    .messaging()
    .send(message)
    .then((response) => {
      console.log("Successful send message : ", response);
    })
    .catch((error) => {
      console.log("Error send message : ", error);
    });

  res.status(200).send();
});
