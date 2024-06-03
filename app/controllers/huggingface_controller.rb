class HuggingfaceController < ApplicationController
  def index
    @result = flash[:result]
  end

  def show
    render :index
  end

  def create
    query = params[:query]
    service = HuggingfaceService.new(query)
    Rails.logger.info "-> Content: #{params}"

    begin
      @result = service.call
      Rails.logger.info "-> Service result: #{@result}"
    rescue => e
      Rails.logger.error "-> Failed to get content: #{e.message}"
      @result = "There was an error processing your request."
    end
    flash[:result] = @result
    redirect_to huggingface_index_path
  end
end