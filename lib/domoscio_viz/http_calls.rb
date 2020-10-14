module DomoscioViz
  module HTTPCalls
    module GetUrl
      module ClassMethods
        # In order to catch current SocketsTimeoutError that seem to appear when the VizEngine stays Idle for too long
        # Perform the request a second time if it fails the fisrt time
        def get_url(util_name = nil, params = {})
          response = DomoscioViz.request(:post, url(util_name), params)
          response = DomoscioViz.request(:post, url(util_name), params) if response.is_a?(Hash) && response['success'] == false
          response
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end      
    end
  end
end