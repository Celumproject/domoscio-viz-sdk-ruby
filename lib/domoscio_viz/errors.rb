module DomoscioViz
  # Generic error superclass for MangoPay specific errors.
  # Currently never instantiated directly.
  # Currently only single subclass used.
  class Error < StandardError
  end
  # ResponseError from VizEngine
  class ResponseError < Error
    attr_reader :request_url, :code, :details, :body, :request_params
    def initialize(request_url, code, details, body, request_params)
      @request_url, @code, @details, @body, @request_params = request_url, code, details, body, request_params
      super(message) if message
    end
    def message; @details.is_a?(Hash) ? @details.dig(:error, :message) : @details; end
  end

  # ProcessingError from Domoscio_viz
  class ProcessingError < Error
    attr_reader :request_url, :code, :details, :body, :request_params
    def initialize(request_url, code, details, body, request_params)
      @request_url, @code, @details, @body, @request_params = request_url, code, details, body, request_params
      super(message) if message
    end
    def message; @details.message; end
  end
end