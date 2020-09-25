module S3AssetManager
  class FolderUpload
    attr_reader :folder_path, :total_files, :s3_bucket, :include_folder, :prefix
    attr_accessor :files

    # Initialize the upload class
    #
    # folder_path - path to the folder that you want to upload
    # bucket - The bucket you want to upload to
    # prefix - prepend the given string as the folder to nest uploads under
    # include_folder - include the root folder on the path? (default: true)
    #
    # Examples
    #   => uploader = FolderUpload.new(folder_path: "/home/test_folder", bucket: "your_bucket_name", prefix: "uploaded_folders/#{Date.today}")
    #   => uploader = FolderUpload.new(folder_path: Rails.root.join("public"), bucket: "public_bucket", prefix: "assets")
    #
    def initialize(folder_path:, bucket:, prefix: "", include_folder: true)
      @folder_path       = folder_path
      @files             = Dir.glob("#{folder_path}/**/*")
      @total_files       = files.length
      @s3_bucket         = bucket
      @include_folder    = include_folder
      @prefix            = prefix.to_s.presence
    end

    # public: Upload files from the folder to S3
    #
    # thread_count - How many threads you want to use (defaults to 5)
    # simulate - Don't perform upload, just simulate it (default: false)
    # verbose - Verbose info (default: false)
    #
    # Examples
    #   => uploader.upload(thread_count: 20)
    #     true
    #   => uploader.upload
    #     true
    #
    # Returns true when finished the process
    def upload(thread_count: 5, simulate: false)
      file_number = 0
      mutex       = Mutex.new
      threads     = []

      Rails.logger.info { " Total files: #{total_files}... (folder #{folder_path} #{include_folder ? "" : "not "}included)" }

      verbose = false if verbose == :silence

      thread_count.times do |i|
        threads[i] = Thread.new {
          until files.empty?
            mutex.synchronize do
              file_number += 1
              Thread.current["file_number"] = file_number
            end
            file = files.pop rescue nil
            next unless file

            # Define destination path
            path = file.sub(/^#{folder_path}\//, "")

            path = "#{File.basename(folder_path)}/#{path}" if include_folder

            path = "#{prefix}/#{path}" if prefix

            Rails.logger.debug { "[#{Thread.current["file_number"]}/#{total_files}] uploading..." }

            data = File.open(file)

            unless File.directory?(data) || simulate
              obj = s3_bucket.object(path)
              obj.put({ acl: "public-read", body: data })
            end

            Rails.logger.debug { "[#{Thread.current["file_number"]}/#{total_files}] uploaded" }

            data.close
          end
        }
      end
      threads.each { |t| t.join }
    end
  end
end
