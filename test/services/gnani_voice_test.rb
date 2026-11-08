require "test_helper"

class GnaniVoiceTest < ActiveSupport::TestCase
  test "extracts the URL from a pasted request line and header" do
    voice = GnaniVoice.new
    configured_value = "POST https://api.vachana.ai/stt/v3\nContent-Type: multipart/form-data"

    assert_equal "https://api.vachana.ai/stt/v3", voice.send(:endpoint_url, configured_value, "GNANI_STT_ENDPOINT")
  end

  test "rejects a value without an HTTP endpoint URL" do
    voice = GnaniVoice.new

    error = assert_raises(GnaniVoice::Error) do
      voice.send(:endpoint_url, "POST /stt/v3\nContent-Type: multipart/form-data", "GNANI_STT_ENDPOINT")
    end

    assert_includes error.message, "without the HTTP method or headers"
  end

  test "reports a missing API key before making a request" do
    voice = GnaniVoice.new
    voice.instance_variable_set(:@api_key, nil)

    error = assert_raises(GnaniVoice::Error) do
      voice.send(:required_api_key)
    end

    assert_equal "GNANI_API_KEY is not configured.", error.message
  end

  test "sends the raw API key as the STT X-API-Key-ID header" do
    voice = GnaniVoice.new
    voice.instance_variable_set(:@api_key, "test-key")
    voice.instance_variable_set(:@stt_endpoint, "https://api.vachana.ai/stt/v3")
    request_context = Struct.new(:headers, :body).new({}, nil)
    upload = Struct.new(:tempfile, :content_type, :original_filename)
      .new(Tempfile.new("audio"), "audio/wav", "question.wav")

    request_stub = lambda do |_endpoint, _operation, &configure_request|
      configure_request.call(request_context)
      :response
    end

    voice.define_singleton_method(:request, &request_stub)
    voice.define_singleton_method(:parse_response) { |_response, _operation| { "transcript" => "hello" } }

    assert_equal "hello", voice.transcribe(upload)

    assert_equal "test-key", request_context.headers["X-API-Key-ID"]
    assert_not request_context.headers.key?("Authorization")
    assert request_context.body.key?("audio_file")
    assert_equal "prisma-v3.0", request_context.body[:model]
    assert_equal "en-IN,hi-IN", request_context.body[:language_code]
    assert_equal "transliterate", request_context.body[:format]
  ensure
    upload&.tempfile&.close!
  end

  test "sends the raw API key as the TTS X-API-Key-ID header" do
    voice = GnaniVoice.new
    voice.instance_variable_set(:@api_key, "test-key")
    voice.instance_variable_set(:@tts_endpoint, "https://api.vachana.ai/api/v1/tts/inference")
    request_context = Struct.new(:headers, :body).new({}, nil)
    wav_audio = "RIFF".b + [0xFFFFFFFF].pack("V") + "WAVEfmt ".b + [16].pack("V") +
      [1, 1, 24_000, 48_000, 2, 16].pack("v2V2v2") + "data".b + [0xFFFFFFFF].pack("V") + "1234".b
    response = Struct.new(:status, :body, :headers) do
      def success?
        (200..299).cover?(status)
      end
    end.new(200, wav_audio, { "content-type" => "audio/wav" })

    voice.define_singleton_method(:request) do |_endpoint, _operation, &configure_request|
      configure_request.call(request_context)
      response
    end

    audio = voice.synthesize("hello")
    assert_equal "audio/wav", audio[:content_type]
    assert_equal "RIFF", audio[:body].byteslice(0, 4)
    assert_equal audio[:body].bytesize - 8, audio[:body].byteslice(4, 4).unpack1("V")
    data_offset = audio[:body].index("data") + 4
    assert_equal audio[:body].bytesize - data_offset - 4, audio[:body].byteslice(data_offset, 4).unpack1("V")
    assert_equal "test-key", request_context.headers["X-API-Key-ID"]
    assert_not request_context.headers.key?("Authorization")
    assert_equal "audio/wav", request_context.headers["Accept"]
    assert_equal(
      {
        "text" => "hello",
        "model" => "timbre-v3.0",
        "voice" => "Shivani",
        "language" => "auto",
        "audio_config" => {
          "sample_rate" => 24000,
          "num_channels" => 1,
          "sample_width" => 2,
          "encoding" => "linear_pcm",
          "container" => "wav"
        }
      },
      JSON.parse(request_context.body)
    )
  end

  test "rejects a successful TTS response that is not WAV audio" do
    voice = GnaniVoice.new
    response = Struct.new(:status, :body, :headers) do
      def success?
        true
      end
    end.new(200, "{\"message\":\"not audio\"}", { "content-type" => "application/json" })

    error = assert_raises(GnaniVoice::Error) do
      voice.send(:parse_audio_response, response, "speech generation")
    end

    assert_includes error.message, "instead of binary audio"
  end

  test "explains that a forbidden response may mean the API key lacks service scope" do
    voice = GnaniVoice.new
    response = Struct.new(:status) do
      def success?
        false
      end
    end.new(403)

    error = assert_raises(GnaniVoice::Error) do
      voice.send(:raise_response_error, response, "speech recognition")
    end

    assert_includes error.message, "SCOPE_NOT_ALLOWED"
  end
end
