require "net/http"
require "json"
require "uri"

class HuggingfaceService
  HOST = "https://router.huggingface.co"
  MODEL = "deepset/roberta-base-squad2"

  def initialize(query, context)
    @query = query
    @context = context
    Rails.logger.info "-> Initialized with query: #{@query} and context: #{@context}"
  end

  def call
    api_key = ENV.fetch("HUGGINGFACE_API_KEY") { Rails.application.credentials.huggingface_api_key }

    if api_key.blank?
      Rails.logger.error "-> HuggingFace API key is missing. Set HUGGINGFACE_API_KEY env var or configure huggingface_api_key in Rails credentials."
      raise "HuggingFace API key is not configured"
    end

    uri = URI("#{HOST}/hf-inference/models/#{MODEL}")
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{api_key}"
    request["Content-Type"] = "application/json"
    request.body = { inputs: { question: @query, context: @context } }.to_json

    Rails.logger.info "-> Sending request to #{uri}"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, read_timeout: 30, open_timeout: 10) do |http|
      http.request(request)
    end

    Rails.logger.info "-> Response status: #{response.code}"
    Rails.logger.info "-> Raw API response: #{response.body}"

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error "-> API request failed: #{response.code} #{response.message}"
      raise "API request failed: #{response.code} #{response.message}"
    end

    parsed = JSON.parse(response.body)
    answer = extract_answer(parsed)

    if answer.nil? || answer.to_s.strip.empty?
      Rails.logger.error "-> API response did not contain a valid answer. Response: #{parsed.inspect}"
      raise "The API did not return a valid answer"
    end

    answer
  rescue JSON::ParserError => e
    Rails.logger.error "-> Failed to parse API response: #{e.message}"
    raise "Invalid API response"
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
