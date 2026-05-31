require "hugging_face"

class HuggingfaceService
  
    def initialize(query, context)
      @query = query
      @context = context
      Rails.logger.info "-> Initialized with query: #{@query} and context: #{@context}"
    end
  
    def call
      api_key = Rails.application.credentials.huggingface_api_key

      if api_key.blank?
        Rails.logger.error "-> HuggingFace API key is missing. Ensure RAILS_MASTER_KEY is set and huggingface_api_key is configured in credentials."
        raise "HuggingFace API key is not configured"
      end

      client = HuggingFace::InferenceApi.new(api_token: api_key)
      Rails.logger.info "-> HuggingFace client initialized"

      question_answering = client.question_answering(
        question: @query,
        context: @context
      )

      Rails.logger.info "-> Raw API response: #{question_answering.inspect}"

      answer = extract_answer(question_answering)

      if answer.nil? || answer.to_s.strip.empty?
        Rails.logger.error "-> API response did not contain a valid answer. Response: #{question_answering.inspect}"
        raise "The API did not return a valid answer"
      end

      answer
    rescue => e
      Rails.logger.error "-> Error in HuggingfaceService: #{e.class}: #{e.message}"
      raise
    end

    private

    def extract_answer(response)
      return nil unless response.is_a?(Hash)

      response["answer"] || response[:answer]
    end
  end