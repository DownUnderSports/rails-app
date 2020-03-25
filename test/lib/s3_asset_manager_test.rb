# encoding: utf-8
# frozen_string_literal: true
module Libraries
  class S3AssetManagerTest < ActiveSupport::TestCase
    test  '.upload_folder initializes a FolderUpload and calls #upload with' do
      original_new = S3AssetManager::FolderUpload.method(:new)
      given_args = given_opts = new_opts = upload_opts = nil
      stubbed_new = ->(*args, **opts) do
        given_args = args.dup
        given_opts = opts.dup
        if opts.present?
          return original_new.call *args, **opts
        else
          return original_new.call *args
        end
      end

      stubbed_upload = ->(*args, **opts) do
        assert_empty args
        upload_opts = opts
        return self
      end

      S3AssetManager::FolderUpload.stub(:new, stubbed_new) do
        S3AssetManager::FolderUpload.stub_instances(:upload, stubbed_upload) do
          instance =
            S3AssetManager.
              upload_folder(Rails.root.join("public").to_s, test_extra_opt: "test")

              expected_opts = {
                folder_path: Rails.root.join("public").to_s,
                bucket: s3_bucket,
                include_folder: false,
                prefix: ''
              }

              assert_equal [], given_args
              assert_hash_equal expected_opts, given_opts
              assert_equal({ test_extra_opt: "test" }, given_opts)
        end
      end
    end
  end
end
# module S3AssetManager
#   def self.upload_folder(folder_path, include_folder: false, bucket: nil, prefix: '', **opts)
#     self::FolderUpload.new(folder_path: folder_path, bucket: bucket || s3_bucket, include_folder: Boolean.parse(include_folder), prefix: prefix).upload! **opts
#   end
#
#   def self.object_if_exists(file_path, asset_prefix = '')
#     o =
#       s3_bucket.
#       object("#{asset_prefix.presence && "#{asset_prefix}/"}#{file_path}")
#
#     o.exists? && o
#   end
# end
