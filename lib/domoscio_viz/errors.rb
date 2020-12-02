module DomoscioViz
  # Generic error superclass for MangoPay specific errors.
  # Currently never instantiated directly.
  # Currently only single subclass used.
  class Error < StandardError
  end
  # ErrorMessage from VizEngine 
  class ResponseError < Error
    attr_reader :request_url, :code, :details, :body
    def initialize(request_url, code, details, body)
      @request_url, @code, @details, @body = request_url, code, details, body
      super(message) if message
    end
    def message; @details.dig(:error, :message) || @details; end
  end

  # ProcessingError from Domoscio_viz
  class ProcessingError < Error
    attr_reader :request_url, :code, :details, :body
    def initialize(request_url, code, details, body)
      @request_url, @code, @details, @body = request_url, code, details, body
      super(message) if message
    end
    def message; @details.message; end
  end
end