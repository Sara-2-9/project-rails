require "hugging_face"

class HuggingfaceService
  
    def initialize(query)
      @query = query
    end
  
    def call
      client = HuggingFace::InferenceApi.new(api_token: Rails.application.credentials.huggingface_api_key)
      question_answering = client.question_answering(
        question: @query,
        context: 'I am the only child. My father named his son John.'
      )
      Rails.logger.info "-> Response: #{question_answering['answer']}"
      response = question_answering['answer']
      response
    end
  end