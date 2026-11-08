# BhashaBite

BhashaBite is a Ruby on Rails recipe assistant for hands-free cooking. Ask a question by recording or uploading audio; the app transcribes it, finds a matching recipe, displays the ingredients and steps, and requests a spoken version of the instructions.

## Features

- Record audio in the browser or upload an audio file.
- Send the question to Gnani AI Prisma (speech-to-text), then match recognized words against recipe names and ingredients.
- Display recipe ingredients and instructions, and narrate the title, ingredients, and steps with Gnani AI Timbre (text-to-speech). Playback starts automatically when the browser permits, with a visible listen/pause control as a fallback. Audio is fetched from Rails as binary; the Gnani key stays server-side.
- Browse recipes grouped into Chinese, North Indian, South Indian, Bengali, Gujarati, and Marathi cuisine sections.
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

Open [http://localhost:3000](http://localhost:3000). Recipes can be browsed without Gnani AI credentials; voice requests require the configuration below. The seed data provides at least three dishes in each cuisine section. Add recipes in `db/seeds.rb`, assign each a cuisine, then run `ruby .\bin\rails db:seed`.

For macOS/Linux, run the same Rails commands using `bin/rails <command>`.

## Configure Gnani AI

The app loads `.env` automatically in development. Edit the existing `.env` file in the project root and fill in your Gnani API key and documented Prisma and Timbre URLs. The Prisma URL is prefilled; verify it against your Gnani documentation. Do not include HTTP method or header lines in endpoint values, and never commit `.env` or share your API key. `.env` is ignored by Git. Voice requests report a clear configuration error until the API key is filled in.

For example:

```dotenv
GNANI_API_KEY=your-real-api-key
GNANI_STT_ENDPOINT=https://api.vachana.ai/stt/v3
GNANI_TTS_ENDPOINT=https://api.vachana.ai/api/v1/tts/inference
```

After saving `.env`, stop Rails with `Ctrl+C` and start it again. The server will load the values from the project file even when launched from a different terminal. In production, configure these as deployment environment variables instead.

| Variable | Required | Description |
|---|---:|---|
| `GNANI_API_KEY` | Yes | Gnani AI API key |
| `GNANI_STT_ENDPOINT` | Yes | Full Prisma speech-to-text endpoint URL |
| `GNANI_TTS_ENDPOINT` | Yes | Full Timbre text-to-speech endpoint URL |
| `GNANI_STT_FILE_FIELD` | No | Multipart audio field name; defaults to `audio_file` |
| `GNANI_STT_MODEL` | No | Prisma model; defaults to `prisma-v3.0` |
| `GNANI_STT_LANGUAGE_CODE` | No | Language hints; defaults to `en-IN,hi-IN` |
| `GNANI_STT_FORMAT` | No | Transcript output format; defaults to `transliterate` (Latin script) |
| `GNANI_STT_TRANSCRIPT_FIELD` | No | STT JSON response field containing the transcript; defaults to `transcript` |
| `GNANI_TTS_MODEL` | No | Timbre model; defaults to `timbre-v3.0` |
| `GNANI_TTS_VOICE` | No | Timbre voice; defaults to `Shivani` |
| `GNANI_TTS_LANGUAGE` | No | TTS language or `auto`; defaults to `auto` |

For both speech-to-text and text-to-speech, the app sends the raw API key in the `X-API-Key-ID` header. STT uses multipart form fields `audio_file`, `model`, `language_code`, and `format`; by default it hints English and Hindi and returns the transcript in Latin script. The endpoint accepts clips up to 30 seconds. TTS sends JSON containing `text`, `model`, `voice`, and `language`, and receives raw WAV audio.

Use only endpoint URLs in the environment variables; do not include HTTP methods or headers. The STT documentation lists WAV, MP3, OGG, FLAC, AAC, and M4A, with a maximum clip duration of 30 seconds. A `403` `SCOPE_NOT_ALLOWED` response means the API key lacks permission for that service; ask Gnani to enable STT and/or TTS access for the key.

The browser recorder needs microphone permission and a secure context: localhost works for development, while deployed sites should use HTTPS. Audio uploads are limited to 25 MB and must be WAV, MP3, OGG, FLAC, AAC, or M4A. The recorder stops at the documented 30-second STT limit.

## Tests

```bash
ruby .\bin\rails test
```

On macOS/Linux, run `bin/rails test`.

## Demo and submission

Record a short demo showing a spoken cooking question, the recognized text, the matching recipe, and its spoken instructions. Share it on LinkedIn or X (Twitter), tag Gnani AI, and use `#GnaniAI` and `#GreatIndianAIInternshipChallenge`. Submit through the official form before **November 10, 2026**.
