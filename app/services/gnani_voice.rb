require "base64"
require "faraday"
require "faraday/multipart"
require "json"
require "uri"

class GnaniVoice
  class Error < StandardError; end

  def initialize
    @api_key = ENV["GNANI_API_KEY"]
    @stt_endpoint = ENV["GNANI_STT_ENDPOINT"]
    @tts_endpoint = ENV["GNANI_TTS_ENDPOINT"]
  end

  def transcribe(upload)
    endpoint = endpoint_url(@stt_endpoint, "GNANI_STT_ENDPOINT")
    required_api_key
    response = request(endpoint, "speech recognition") do |request|
      request.headers["X-API-Key-ID"] = required_api_key
      request.headers["Accept"] = "application/json"
      request.body = {
        ENV.fetch("GNANI_STT_FILE_FIELD", "audio_file") =>
          Faraday::Multipart::FilePart.new(
            upload.tempfile,
            upload.content_type.to_s.split(";").first,
            upload.original_filename
          ),
        model: ENV.fetch("GNANI_STT_MODEL", "prisma-v3.0"),
        language_code: ENV.fetch("GNANI_STT_LANGUAGE_CODE", "indic-auto")
      }
    end
    payload = parse_response(response, "speech recognition")
    transcript = payload[ENV.fetch("GNANI_STT_TRANSCRIPT_FIELD", "transcript")].to_s.strip
    raise Error, "Speech recognition returned an empty transcript." if transcript.blank?

    transcript
  end

  def synthesize(text)
    endpoint = endpoint_url(@tts_endpoint, "GNANI_TTS_ENDPOINT")
    required_api_key
    response = request(endpoint, "speech generation") do |request|
      request.headers["X-API-Key-ID"] = required_api_key
      request.headers["Content-Type"] = "application/json"
      request.headers["Accept"] = "audio/wav"
      request.body = {
        text: text,
        model: ENV.fetch("GNANI_TTS_MODEL", "timbre-v3.0"),
        voice: ENV.fetch("GNANI_TTS_VOICE", "Shivani"),
        language: ENV.fetch("GNANI_TTS_LANGUAGE", "auto")
      }.to_json
    end
    parse_audio_response(response, "speech generation")
  end

  private

  def connection
    @connection ||= Faraday.new do |faraday|
      faraday.request :multipart
      faraday.request :url_encoded
      faraday.options.timeout = 60
      faraday.options.open_timeout = 10
      faraday.adapter Faraday.default_adapter
    end
  end

  def required_api_key
    required_setting(@api_key, "GNANI_API_KEY")
  end

  def required_setting(value, name)
    value.presence || raise(Error, "#{name} is not configured.")
  end

  def endpoint_url(value, name)
    configured_value = required_setting(value, name).strip
    url = configured_value.match(%r{https?://[^\s"'<>]+}i)&.[](0) || configured_value
    uri = URI.parse(url)

    unless uri.is_a?(URI::HTTP) && uri.host.present? && uri.userinfo.nil?
      raise Error, "#{name} must contain an HTTP or HTTPS endpoint URL only, without the HTTP method or headers."
    end

    uri.to_s
  rescue URI::InvalidURIError
    raise Error, "#{name} must contain an HTTP or HTTPS endpoint URL only, without the HTTP method or headers."
  end

  def request(endpoint, operation, &block)
    connection.post(endpoint, &block)
  rescue Faraday::Error => error
    raise Error, "Gnani AI #{operation} request could not be completed: #{error.message}"
  end

  def parse_response(response, operation)
    raise_response_error(response, operation)

    payload = JSON.parse(response.body)
    raise Error, "Gnani AI #{operation} returned an unexpected response." unless payload.is_a?(Hash)

    payload
  rescue JSON::ParserError
    raise Error, "Gnani AI #{operation} returned an invalid JSON response."
  end

  def parse_audio_response(response, operation)
    raise_response_error(response, operation)
    raise Error, "Gnani AI #{operation} returned an empty audio response." if response.body.blank?

    content_type = response.headers["content-type"].to_s.split(";").first.presence || "audio/wav"
    { data_uri: "data:#{content_type};base64,#{Base64.strict_encode64(response.body)}" }
  end

  def raise_response_error(response, operation)
    return if response.success?

    if response.status == 403
      raise Error, "Gnani AI #{operation} access forbidden (HTTP 403). The API key may not have permission for this service (SCOPE_NOT_ALLOWED)."
    end

    raise Error, "Gnani AI #{operation} request failed (HTTP #{response.status})."
  end
end
