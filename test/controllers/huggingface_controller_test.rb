require "test_helper"

class HuggingfaceControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get huggingface_index_url
    assert_response :success
  end

  test "should redirect on create" do
    post huggingface_index_url, params: { query: "What is Ruby?", context: "Ruby is a programming language." }
    assert_redirected_to huggingface_index_path
  end

  test "should show descriptive error when service fails" do
    fake_service = Object.new
    def fake_service.call
      raise "Simulated API failure"
    end

    original_new = HuggingfaceService.method(:new)
    HuggingfaceService.define_singleton_method(:new) { |*args| fake_service }

    post huggingface_index_url, params: { query: "test", context: "test" }
    assert_redirected_to huggingface_index_path
    assert_equal "Error: Simulated API failure", flash[:result]
  ensure
    HuggingfaceService.define_singleton_method(:new, original_new)
  end
end
