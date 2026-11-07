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
end
