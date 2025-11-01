const functions = require("firebase-functions");
const admin = require("firebase-admin");
const speech = require("@google-cloud/speech").v1p1beta1;
const fs = require("fs");
const path = require("path");
const os = require("os");

admin.initializeApp();

const client = new speech.SpeechClient();

// This function is triggered manually — not by upload
exports.transcribeExistingAudio = functions.https.onCall(async (request, context) => {
    console.log("Raw incoming data:", JSON.stringify(request.data));
    console.log("Context auth:", context.auth);
    try {

        const { userId, noteId, audioUrl } = request.data || {};

        console.log("Parsed:", { userId, noteId, audioUrl });

        if (!userId || !audioUrl || !noteId) {
            console.error("Missing parameters:", { userId, noteId, audioUrl });
            throw new Error("Missing docId or audioUrl or userId");
        }

        // Download the file from Firebase Storage
        const bucket = admin.storage().bucket();
        const filePath = decodeURIComponent(audioUrl.split("/o/")[1].split("?")[0]);
        const tempFilePath = path.join(os.tmpdir(), path.basename(filePath));

        await bucket.file(filePath).download({ destination: tempFilePath });

        const audioBytes = fs.readFileSync(tempFilePath).toString("base64");

        const audio = { content: audioBytes };
        const config = {
            encoding: "LINEAR16",
            languageCode: "en-US",
            enableAutomaticPunctuation: true,
        };

        const [response] = await client.recognize({ audio, config });

        const transcription = response.results
            .map((r) => r.alternatives[0].transcript)
            .join("\n");

        // Update the existing note document
        await admin.firestore().collection("users").doc(userId).collection("notes").doc(noteId).update({
            'transcript': transcription,
        });

        fs.unlinkSync(tempFilePath);
        return { success: true, transcript: transcription };
    } catch (error) {
        console.error("Error transcribing existing audio:", error);
        throw new functions.https.HttpsError("internal", error.message);
    }
});
