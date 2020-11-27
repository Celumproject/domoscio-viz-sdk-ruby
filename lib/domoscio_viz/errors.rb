module DomoscioViz
  # Generic error superclass for MangoPay specific errors.
  # Currently never instantiated directly.
  # Currently only single subclass used.
  class Error < StandardError
  end
  # ErrorMessage from VizEngine 
  class ResponseError < Error
    attr_reader :request_url, :code, :details

    def initialize(request_url, code, details)
      @request_url, @code, @details = request_url, code, details
      super(message) if message
    end
    def message; @details.dig(:error, :message) || @details; end
  end
  # Processing Error from DomoscioViz
  class ProcessingError < Error
    attr_reader :request_url, :code, :details
    def initialize(request_url, code, details)
      @request_url, @code, @details = request_url, code, details
      super(message) if message
    end
    def message; @details.message; end
  end
end