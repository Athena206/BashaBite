# Rasoi Tale

Rasoi Tale is a cozy, voice-enabled recipe finder. Search by dish, cuisine, ingredient, or instruction, filter recipes by Veg or Non-veg, or ask hands-free by recording/uploading a short audio question. Browse recipes by cuisine and listen to narrated ingredients and cooking steps.

## Features

- Search recipes with plain text across recipe names, cuisines, ingredients, and instructions.
- Filter the recipe collection by Veg or Non-veg, alone or alongside text search.
- Browse recipe cards grouped into Chinese, North Indian, South Indian, Bengali, Gujarati, and Marathi cuisines.
- Record a voice question in the browser or upload an audio file; Gnani AI Prisma transcribes it and the app finds a matching recipe.
- View recipe ingredients and numbered cooking steps.
- Listen to the recipe title, ingredients, and instructions using Gnani AI Timbre. Playback starts automatically when permitted; a **Listen to recipe** control is available if the browser blocks autoplay.
- Responsive interface with food photos, cuisine icons, and recipe cards.

## Requirements

- Ruby 3.2 or newer
- Bundler
- SQLite
- Gnani AI API key with the required STT and TTS service access for voice features

## Run locally

From PowerShell on Windows:

```powershell
bundle install
ruby .\bin\rails db:prepare
ruby .\bin\rails db:seed
ruby .\bin\rails server
```

Open [http://localhost:3000](http://localhost:3000). Search and recipe browsing work without Gnani credentials; recording, transcription, and narration require API configuration.

On macOS/Linux, use `bin/rails <command>` in place of `ruby .\bin\rails <command>`.

### Tests

```powershell
ruby .\bin\rails test
```

On macOS/Linux, run `bin/rails test`.

## Configure Gnani AI

In the project root, copy `.env.example` to `.env` (or update the existing `.env`) and set your API key. The app loads `.env` automatically in development. Keep the key private: `.env` is Git-ignored, but do not commit it or paste the key into source files. Restart the Rails server after changing environment values. In production, set environment variables through your deployment platform.

```dotenv
GNANI_API_KEY=your-gnani-api-key
GNANI_STT_ENDPOINT=https://api.vachana.ai/stt/v3
GNANI_TTS_ENDPOINT=https://api.vachana.ai/api/v1/tts/inference
```

The app sends the raw key in the `X-API-Key-ID` header for both APIs.

| Variable | Required | Default | Description |
|---|---:|---|---|
| `GNANI_API_KEY` | Yes | — | Gnani API key with STT/TTS access |
| `GNANI_STT_ENDPOINT` | Yes | — | Prisma speech-to-text endpoint |
| `GNANI_TTS_ENDPOINT` | Yes | — | Timbre text-to-speech endpoint |
| `GNANI_STT_FILE_FIELD` | No | `audio_file` | Multipart audio field name |
| `GNANI_STT_MODEL` | No | `prisma-v3.0` | Prisma model |
| `GNANI_STT_LANGUAGE_CODE` | No | `en-IN,hi-IN` | Language hints |
| `GNANI_STT_FORMAT` | No | `transliterate` | Transcript format; transliteration returns Latin script |
| `GNANI_STT_TRANSCRIPT_FIELD` | No | `transcript` | STT JSON field containing recognized text |
| `GNANI_TTS_MODEL` | No | `timbre-v3.0` | Timbre model |
| `GNANI_TTS_VOICE` | No | `Shivani` | Timbre voice |
| `GNANI_TTS_LANGUAGE` | No | `auto` | Language of text sent to TTS |

STT audio is sent as multipart data with `audio_file`, `model`, `language_code`, and `format` fields. The documented endpoint accepts WAV, MP3, OGG, FLAC, AAC, and M4A clips up to 30 seconds. The browser recorder stops at 30 seconds, and uploads are limited to 25 MB.

TTS sends JSON with the recipe narration, model, voice, language, and WAV audio settings. Gnani returns binary WAV data; the Rails audio endpoint repairs the WAV length fields when needed, and the browser plays it using a Blob object URL. The API key remains on the server.

A `403` response with `SCOPE_NOT_ALLOWED` means the key lacks permission for that service. Ask Gnani to enable STT and/or TTS access for the key. A browser microphone requires permission; `localhost` is a secure context for development, while deployed sites should use HTTPS.

## Add recipes

Add a recipe entry to `db/seeds.rb` with a unique title, ingredients, instructions, and one cuisine from `Recipe::CUISINES`, then run:

```powershell
ruby .\bin\rails db:seed
```

Seed updates are safe to rerun: existing recipes with the same title are updated.
