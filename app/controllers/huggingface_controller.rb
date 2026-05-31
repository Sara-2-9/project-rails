class HuggingfaceController < ApplicationController
  def index
    @result = flash[:result]
  end

  def show
    render :index
  end

  def create
    query = params[:query].to_s.strip
    context = params[:context].to_s.strip

    if query.blank? || context.blank?
      flash[:result] = "Error: Question and Context are required."
      redirect_to huggingface_index_path
      return
    end

    service = HuggingfaceService.new(query, context)
    Rails.logger.info "-> Params received: query: #{query}, context: #{context}"

    begin
      @result = service.call
      Rails.logger.info "-> Service result: #{@result}"
    rescue => e
      Rails.logger.error "-> Failed to get content: #{e.class}: #{e.message}"
      @result = "Error: #{e.message}"
    end
    flash[:result] = @result
    redirect_to huggingface_index_path
  end
end