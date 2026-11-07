# BhashaBite

BhashaBite is a Ruby on Rails recipe assistant for hands-free cooking. Ask a question by recording or uploading audio; the app transcribes it, finds a matching recipe, displays the ingredients and steps, and requests a spoken version of the instructions.

## Features

- Record audio in the browser or upload an audio file.
- Send the question to Gnani AI Prisma (speech-to-text), then match recognized words against recipe names and ingredients.
- Display recipe ingredients and instructions, and request audio from Gnani AI Timbre (text-to-speech).
- Browse six sample regional recipes: Aloo Posto, Masala Dosa, Gujarati Kadhi, Poha, Rajma, and Sambar.
- Surface missing configuration, API, upload, and recipe-match errors instead of choosing a random recipe.

## Requirements

- Ruby 3.2 or newer
- Bundler
- SQLite
- Gnani AI API credentials and the documented Prisma/Timbre API endpoints for voice features

## Run locally

```bash
bundle install
ruby .\bin\rails db:prepare
ruby .\bin\rails db:seed
ruby .\bin\rails server
```

Open [http://localhost:3000](http://localhost:3000). Recipes can be browsed without Gnani AI credentials; voice requests require the configuration below.

For macOS/Linux, run the same Rails commands using `bin/rails <command>`.

## Configure Gnani AI

The app loads `.env` automatically in development. Edit the existing `.env` file in the project root and fill in your Gnani API key and documented Prisma and Timbre URLs. The Prisma URL is prefilled; verify it against your Gnani documentation. Do not include HTTP method or header lines in endpoint values, and never commit `.env` or share your API key. `.env` is ignored by Git. Voice requests report a clear configuration error until the API key is filled in.

For example:

```dotenv
GNANI_API_KEY=your-real-api-key
GNANI_STT_ENDPOINT=https://api.vachana.ai/stt/v3
GNANI_TTS_ENDPOINT=https://your-documented-timbre-endpoint
```

After saving `.env`, stop Rails with `Ctrl+C` and start it again. The server will load the values from the project file even when launched from a different terminal. In production, configure these as deployment environment variables instead.

| Variable | Required | Description |
|---|---:|---|
| `GNANI_API_KEY` | Yes | Gnani AI API key |
| `GNANI_STT_ENDPOINT` | Yes | Full Prisma speech-to-text endpoint URL |
| `GNANI_TTS_ENDPOINT` | Yes | Full Timbre text-to-speech endpoint URL |
| `GNANI_STT_FILE_FIELD` | No | Multipart audio field name; defaults to `file` |
| `GNANI_STT_TRANSCRIPT_FIELD` | No | STT JSON response field containing the transcript; defaults to `transcript` |
| `GNANI_TTS_AUDIO_URL_FIELD` | No | TTS JSON field containing a playable audio URL; defaults to `audio_url` |
| `GNANI_TTS_AUDIO_BASE64_FIELD` | No | TTS JSON field containing base64 audio; defaults to `audio_base64` |
| `GNANI_TTS_CONTENT_TYPE_FIELD` | No | TTS JSON field containing the audio MIME type; defaults to `content_type` |

Set each endpoint variable to only the endpoint URL, for example `https://api.example.com/path`. Do not include `POST`, `Content-Type`, or other headers in the endpoint value. The app sends STT audio as a multipart upload with a Bearer authorization header and sends TTS text as JSON (`{"text":"..."}`). It accepts a transcript string from STT and either an audio URL or base64 audio from TTS. Confirm the exact endpoint URLs, authentication method, multipart field, request payload, response fields, and supported formats in the Gnani AI documentation for your account. Adjust the field-name settings to match that documented API. The app deliberately does not assume undocumented endpoint URLs.

The browser recorder needs microphone permission and a secure context: localhost works for development, while deployed sites should use HTTPS. Audio uploads are limited to 25 MB and supported formats are WebM, Ogg, WAV, MP3, AAC, and MP4.

## Tests

```bash
ruby .\bin\rails test
```

On macOS/Linux, run `bin/rails test`.

## Demo and submission

Record a short demo showing a spoken cooking question, the recognized text, the matching recipe, and its spoken instructions. Share it on LinkedIn or X (Twitter), tag Gnani AI, and use `#GnaniAI` and `#GreatIndianAIInternshipChallenge`. Submit through the official form before **November 10, 2026**.
