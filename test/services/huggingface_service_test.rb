require "test_helper"

class HuggingfaceServiceTest < ActiveSupport::TestCase
  test "raises error when api key is missing" do
    original_env = ENV.to_h
    ENV.delete("HUGGINGFACE_API_KEY")

    service = HuggingfaceService.new("test", "test")
    error = assert_raises(RuntimeError) { service.call }
    assert_equal "HuggingFace API key is not configured", error.message
  ensure
    ENV.replace(original_env)
  end

  test "extract_answer returns string answer from hash with string key" do
    service = HuggingfaceService.new("test", "test")
    assert_equal "Paris", service.send(:extract_answer, { "answer" => "Paris" })
  end

  test "extract_answer returns string answer from hash with symbol key" do
    service = HuggingfaceService.new("test", "test")
    assert_equal "Paris", service.send(:extract_answer, { answer: "Paris" })
  end

  test "extract_answer returns nil for empty hash" do
    service = HuggingfaceService.new("test", "test")
    assert_nil service.send(:extract_answer, {})
  end

  test "extract_answer returns nil for non-hash response" do
    service = HuggingfaceService.new("test", "test")
    assert_nil service.send(:extract_answer, "not a hash")
    assert_nil service.send(:extract_answer, nil)
    assert_nil service.send(:extract_answer, 123)
  end
end
