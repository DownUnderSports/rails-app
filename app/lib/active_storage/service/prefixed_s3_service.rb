require_relative './s3_service'

module ActiveStorage
  class Service
    class PrefixedS3Service < S3Service
      attr_reader :client, :bucket, :prefix, :upload_options

      def initialize(bucket:, upload: {}, **options)
        @prefix = options.delete(:prefix)
        super(bucket: bucket, upload: upload, **options)
      end

      private
        def object_for(key)
          path = prefix.present? ? File.join(prefix, key) : key
          bucket.object(path)
        end
    end
  end
end
