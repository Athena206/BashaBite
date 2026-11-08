const form = document.getElementById("voice-form");

document.querySelectorAll(".recipe-image, .featured-food-image").forEach((image) => {
  image.addEventListener("error", () => image.classList.add("image-unavailable"), { once: true });
});

document.querySelectorAll("[data-gnani-audio]").forEach((player) => {
  const container = player.closest(".audio-player");
  const status = container.querySelector("[data-audio-status]");
  const playButton = container.querySelector("[data-audio-play]");
  let objectUrl;

  const loadAudio = fetch(player.dataset.audioUrl)
    .then((response) => {
      if (!response.ok) {
        return response.text().then((message) => {
          throw new Error(message || "Could not load spoken instructions.");
        });
      }
      return response.blob();
    })
    .then((blob) => {
      if (!blob.size) throw new Error("Gnani returned empty audio.");
      objectUrl = URL.createObjectURL(blob);
      player.src = objectUrl;
      player.load();
      playButton.disabled = false;
      playButton.textContent = "Listen to recipe";
      status.textContent = "Your recipe instructions are ready.";
      return player;
    })
    .catch((error) => {
      status.textContent = error.message;
      status.classList.add("voice-error");
      playButton.textContent = "Voice unavailable";
      throw error;
    });

  loadAudio
    .then(() => player.play())
    .then(() => {
      status.textContent = "Reading the recipe instructions aloud…";
    })
    .catch((error) => {
      if (error.name === "NotAllowedError") {
        status.textContent = "Tap “Listen to recipe” to hear the instructions.";
      } else if (objectUrl) {
        status.textContent = `Could not start the narration: ${error.message}`;
        status.classList.add("voice-error");
      }
    });

  playButton.addEventListener("click", async () => {
    if (!objectUrl) return;

    try {
      if (player.paused) {
        await player.play();
      } else {
        player.pause();
      }
    } catch (error) {
      status.textContent = error.message;
      status.classList.add("voice-error");
    }
  });

  player.addEventListener("play", () => {
    playButton.textContent = "Pause narration";
    status.textContent = "Reading the recipe instructions aloud…";
  });
  player.addEventListener("pause", () => {
    playButton.textContent = "Listen to recipe";
    if (!player.ended) status.textContent = "Narration paused.";
  });
  player.addEventListener("ended", () => {
    playButton.textContent = "Listen again";
    status.textContent = "Recipe narration complete.";
  });
  player.addEventListener("error", () => {
    status.textContent = "The audio could not be played. Tap to try loading it again.";
    status.classList.add("voice-error");
  });

  window.addEventListener("pagehide", () => {
    if (objectUrl) URL.revokeObjectURL(objectUrl);
  }, { once: true });

  loadAudio.catch(() => {});
});

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
  let recordingSeconds = 0;

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

    const mimeType = ["audio/mp4", "audio/ogg;codecs=opus", "audio/aac"]
      .find((type) => MediaRecorder.isTypeSupported(type));
    if (!mimeType) {
      recordStatus.textContent = "This browser cannot record an API-supported audio format. Upload a WAV, MP3, OGG, FLAC, AAC, or M4A file instead.";
      return;
    }

    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      recorder = new MediaRecorder(stream, { mimeType });
      audioChunks = [];
      recorder.addEventListener("dataavailable", (event) => {
        if (event.data.size) audioChunks.push(event.data);
      });
      recorder.addEventListener("stop", () => {
        clearInterval(timerInterval);
        stream.getTracks().forEach((track) => track.stop());
        const audio = new Blob(audioChunks, { type: recorder.mimeType || "audio/webm" });
        const extension = audio.type.includes("mp4") ? "m4a" : audio.type.includes("ogg") ? "ogg" : "aac";
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
      recordingSeconds = 0;
      recordButton.classList.add("is-recording");
      recordButton.setAttribute("aria-label", "Stop recording");
      recordStatus.textContent = "Listening… tap the button to finish";
      timer.textContent = "00:00";
      timerInterval = setInterval(() => {
        recordingSeconds += 1;
        timer.textContent = `${String(Math.floor(recordingSeconds / 60)).padStart(2, "0")}:${String(recordingSeconds % 60).padStart(2, "0")}`;
        if (recordingSeconds >= 30) recorder.stop();
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
