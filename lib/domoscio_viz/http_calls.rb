module DomoscioViz
  module HTTPCalls
    module GetUrl
      module ClassMethods
        def get_url(util_name = nil, params = {})
          DomoscioViz.request(:post, url(util_name), params)
        end
      end
      def self.included(base)
        base.extend(ClassMethods)
      end      
    end
  end
end