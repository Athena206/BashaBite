class RecipesController < ApplicationController
  AUDIO_CONTENT_TYPES = %w[
    audio/webm audio/ogg audio/wav audio/x-wav audio/mpeg audio/mp4 audio/aac
  ].freeze
  MAX_AUDIO_SIZE = 25.megabytes

  def index
    @recipes = Recipe.alphabetical
  end

  def show
    @recipe = Recipe.find(params[:id])
  end

  def audio
    recipe = Recipe.find(params[:id])
    audio = GnaniVoice.new.synthesize_audio(recipe.instructions)
    send_data audio.fetch(:body), type: audio.fetch(:content_type), disposition: "inline"
  rescue GnaniVoice::Error => error
    render plain: error.message, status: :bad_gateway
  end

  def voice_assistant
    upload = params[:audio_file]
    validate_audio_upload!(upload)

    voice = GnaniVoice.new
    @transcript = voice.transcribe(upload)
    @recipe = RecipeSearch.call(@transcript)

    @not_found = true unless @recipe

    @recipes = Recipe.alphabetical
    render :index, status: :ok
  rescue GnaniVoice::Error => error
    @recipes = Recipe.alphabetical
    @voice_error = error.message
    render :index, status: :unprocessable_entity
  end

  private

  def validate_audio_upload!(upload)
    unless upload.is_a?(ActionDispatch::Http::UploadedFile)
      raise GnaniVoice::Error, "Record or upload an audio question first."
    end
    raise GnaniVoice::Error, "The audio file is empty." if upload.size.zero?
    raise GnaniVoice::Error, "Audio files must be 25 MB or smaller." if upload.size > MAX_AUDIO_SIZE
    content_type = upload.content_type.to_s.split(";").first.downcase
    unless AUDIO_CONTENT_TYPES.include?(content_type)
      raise GnaniVoice::Error, "Unsupported audio format. Upload WebM, Ogg, WAV, MP3, AAC, or MP4 audio."
    end
  end
end
