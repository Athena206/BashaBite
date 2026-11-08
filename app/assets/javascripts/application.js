const form = document.getElementById("voice-form");

if (form) {
  const recordButton = document.getElementById("record-button");
  const recordStatus = document.getElementById("record-status");
  const timer = document.getElementById("recording-timer");
  const audioInput = document.getElementById("audio-file");
  const uploadButton = document.getElementById("upload-button");
  const submitButton = document.getElementById("submit-button");
  let recorder;
  let audioChunks = [];
  let timerInterval;

  uploadButton.addEventListener("click", () => audioInput.click());
  audioInput.addEventListener("change", () => {
    submitButton.disabled = !audioInput.files.length;
    if (audioInput.files.length) recordStatus.textContent = audioInput.files[0].name;
  });

  recordButton.addEventListener("click", async () => {
    if (recorder?.state === "recording") {
      recorder.stop();
      return;
    }

    if (!navigator.mediaDevices?.getUserMedia || !window.MediaRecorder) {
      recordStatus.textContent = "Recording is not supported in this browser. Upload an audio file instead.";
      return;
    }

    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      recorder = new MediaRecorder(stream);
      audioChunks = [];
      recorder.addEventListener("dataavailable", (event) => {
        if (event.data.size) audioChunks.push(event.data);
      });
      recorder.addEventListener("stop", () => {
        clearInterval(timerInterval);
        stream.getTracks().forEach((track) => track.stop());
        const audio = new Blob(audioChunks, { type: recorder.mimeType || "audio/webm" });
        const extension = audio.type.includes("mp4") ? "m4a" : "webm";
        const file = new File([audio], `bhashabite-question.${extension}`, { type: audio.type });
        const transfer = new DataTransfer();
        transfer.items.add(file);
        audioInput.files = transfer.files;
        submitButton.disabled = false;
        recordButton.classList.remove("is-recording");
        recordButton.setAttribute("aria-label", "Start recording");
        recordStatus.textContent = "Your question is ready";
        timer.textContent = "Tap “Find my recipe” to continue";
      });
      recorder.start();
      let recordingSeconds = 0;
      recordButton.classList.add("is-recording");
      recordButton.setAttribute("aria-label", "Stop recording");
      recordStatus.textContent = "Listening… tap the button to finish";
      timer.textContent = "00:00";
      timerInterval = setInterval(() => {
        recordingSeconds += 1;
        timer.textContent = `${String(Math.floor(recordingSeconds / 60)).padStart(2, "0")}:${String(recordingSeconds % 60).padStart(2, "0")}`;
        if (recordingSeconds >= 120) recorder.stop();
      }, 1000);
    } catch (error) {
      recordStatus.textContent = error.name === "NotAllowedError"
        ? "Microphone access was denied. You can upload an audio file instead."
        : "Could not start recording. Please try uploading an audio file.";
    }
  });

  form.addEventListener("submit", () => {
    submitButton.disabled = true;
    submitButton.value = "Listening to your question…";
  });
}

const playAudioButton = document.getElementById("play-audio-button");
const audioPlayer = document.getElementById("recipe-audio-player");
const audioError = document.getElementById("recipe-audio-error");
let audioObjectUrl;

if (playAudioButton && audioPlayer) {
  playAudioButton.addEventListener("click", async () => {
    playAudioButton.disabled = true;
    playAudioButton.textContent = "Preparing audio…";
    audioError.hidden = true;

    try {
      const response = await fetch(playAudioButton.dataset.audioUrl, {
        method: "POST",
        headers: { Accept: "audio/*" },
        credentials: "same-origin"
      });
      if (!response.ok) {
        const message = await response.text();
        throw new Error(message || `Audio request failed (${response.status}).`);
      }

      const blob = await response.blob();
      if (!blob.size || !blob.type.startsWith("audio/")) {
        throw new Error("The speech service did not return playable audio.");
      }

      if (audioObjectUrl) URL.revokeObjectURL(audioObjectUrl);
      audioObjectUrl = URL.createObjectURL(blob);
      audioPlayer.src = audioObjectUrl;
      audioPlayer.hidden = false;
      audioPlayer.load();
      playAudioButton.textContent = "Prepare spoken recipe again";
    } catch (error) {
      audioError.textContent = error.message || "Could not prepare recipe audio. Please try again.";
      audioError.hidden = false;
      playAudioButton.textContent = "Play spoken recipe";
    } finally {
      playAudioButton.disabled = false;
    }
  });

  window.addEventListener("beforeunload", () => {
    if (audioObjectUrl) URL.revokeObjectURL(audioObjectUrl);
  });
}
