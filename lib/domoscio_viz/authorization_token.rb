module DomoscioViz
  module AuthorizationToken
    class Manager

      class << self
        def storage
          @@storage ||= FileStorage.new
        end

        def storage= (storage)
          @@storage = storage
        end

        def get_token
          storage.get
        end
      end
    end

    class StaticStorage
      def get
        @@token ||= nil
      end

      def store(token)
        @@token = token
      end
    end

    class FileStorage
      require 'yaml'
      @temp_dir

      def initialize(temp_dir = nil)
        @temp_dir = temp_dir || DomoscioViz.configuration.temp_dir
        raise "Path to temporary folder is not defined" unless @temp_dir
      end

      def get
        begin
          f = File.open(file_path, File::RDONLY)
          f.flock(File::LOCK_SH)
          txt = f.read
          f.close
          YAML.load(txt) || nil
        rescue Errno::ENOENT
          nil
        end
      end

      def store(token)
        File.open(file_path, File::RDWR|File::CREAT, 0644) do |f|
          f.flock(File::LOCK_EX)
          f.truncate(0)
          f.rewind
          f.puts(YAML.dump(token))
        end
      end

      def file_path
        File.join(@temp_dir, "DomoscioViz.AuthorizationToken.FileStore.tmp")
      end
    end
  end
end