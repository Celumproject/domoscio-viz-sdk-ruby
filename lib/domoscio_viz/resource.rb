module DomoscioViz
  # @abstract
  class Resource
    class << self
      def class_name
        name.split('::')[-1]
      end

      def url(util_name = nil, on_self = nil )
        if self == Resource
          raise NotImplementedError.new('Resource is an abstract class. Do not use it directly.')
        end
        
        build_url = ""
        if !on_self
          if util_name
            build_url << "/#{util_name}"
          end
        end
        return build_url  
      end
    end
  end
end