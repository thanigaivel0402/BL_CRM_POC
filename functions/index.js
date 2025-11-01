const functions = require("firebase-functions");
const admin = require("firebase-admin");
const speech = require("@google-cloud/speech").v1p1beta1;
const fs = require("fs");
const path = require("path");
const os = require("os");

admin.initializeApp();

const client = new speech.SpeechClient({
    keyFilename: path.join(__dirname, "service-account.json"),
});

// This function is triggered manually — not by upload
exports.transcribeExistingAudio = functions.https.onCall(async (data, context) => {
    try {
        const { userId, noteId, audioUrl } = data;

        console.debug(userId, noteId, audioUrl);

        if (!userId || !audioUrl || !noteId) {
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
            encoding: "MP3", // use LINEAR16 for WAV or FLAC for FLAC files
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
