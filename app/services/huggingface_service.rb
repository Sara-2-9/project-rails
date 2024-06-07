require "hugging_face"

class HuggingfaceService
  
    def initialize(query, context)
      @query = query
      @context = context
      Rails.logger.info "-> Initialized with query: #{@query} and context: #{@context}"
    end
  
    def call
      client = HuggingFace::InferenceApi.new(api_token: Rails.application.credentials.huggingface_api_key)
      Rails.logger.info "-> HuggingFace client initialized"

      question_answering = client.question_answering(
        question: @query,
        context: @context
      )
      Rails.logger.info "-> Response: #{question_answering['answer']}"
      response = question_answering['answer']
      response
    rescue => e
      Rails.logger.error "-> Error in HuggingfaceService: #{e.message}"
      raise
    end
  end