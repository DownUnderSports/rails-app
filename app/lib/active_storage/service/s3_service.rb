require 'aws-sdk-s3'
require "#{Gem::Specification.find_by_name('activestorage').gem_dir}/lib/active_storage/service/s3_service"
require 'active_support/core_ext/numeric/bytes'

module ActiveStorage
  class Service
    class S3Service < Service
      def read_bytes(key, range_start = 4, range_end = nil)
        range_start, range_end = 0, range_start - 1 if range_end.nil?
        object_for(key).get(range: "bytes=#{range_start}-#{range_end}").body.read
      end
    end
  end
end
