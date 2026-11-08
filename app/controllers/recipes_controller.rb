class RecipesController < ApplicationController
  AUDIO_CONTENT_TYPES = %w[
    audio/ogg audio/wav audio/x-wav audio/mpeg audio/mp4 audio/aac audio/flac audio/x-flac audio/x-m4a
  ].freeze
  MAX_AUDIO_SIZE = 25.megabytes

  def index
    @recipes = Recipe.alphabetical
    set_recipes_by_cuisine
  end

  def show
    @recipe = Recipe.find(params[:id])
  end

  def voice_assistant
    upload = params[:audio_file]
    validate_audio_upload!(upload)

    voice = GnaniVoice.new
    @transcript = voice.transcribe(upload)
    @recipe = RecipeSearch.call(@transcript)

    if @recipe
      @audio = voice.synthesize(@recipe.instructions)
    else
      @not_found = true
    end

    @recipes = Recipe.alphabetical
    set_recipes_by_cuisine
    render :index, status: :ok
  rescue GnaniVoice::Error => error
    @recipes = Recipe.alphabetical
    set_recipes_by_cuisine
    @voice_error = error.message
    render :index, status: :unprocessable_entity
  end

  private

  def set_recipes_by_cuisine
    @recipes_by_cuisine = Recipe::CUISINES.filter_map do |cuisine|
      recipes = @recipes.select { |recipe| recipe.cuisine == cuisine }
      [cuisine, recipes] if recipes.any?
    end.to_h
  end

  def validate_audio_upload!(upload)
    unless upload.is_a?(ActionDispatch::Http::UploadedFile)
      raise GnaniVoice::Error, "Record or upload an audio question first."
    end
    raise GnaniVoice::Error, "The audio file is empty." if upload.size.zero?
    raise GnaniVoice::Error, "Audio files must be 25 MB or smaller." if upload.size > MAX_AUDIO_SIZE
    content_type = upload.content_type.to_s.split(";").first.downcase
    unless AUDIO_CONTENT_TYPES.include?(content_type)
      raise GnaniVoice::Error, "Unsupported audio format. Gnani supports WAV, MP3, OGG, FLAC, AAC, and M4A audio."
    end
  end
end
