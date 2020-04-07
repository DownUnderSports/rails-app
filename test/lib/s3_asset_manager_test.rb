# encoding: utf-8
# frozen_string_literal: true
module Libraries
  class S3AssetManagerTest < ActiveSupport::TestCase
    def sample_files_path
      Rails.root.join('test', 'lib', 's3_asset_manager', 'sample_files').to_s
    end

    def sample_files
      Dir.glob("#{sample_files_path}/**/*")
    end

    def with_temporary_bucket_path
      prefix = "manager_testing_#{rand}"
      s3_bucket.objects({ prefix: prefix }).batch_delete!
      yield prefix
    ensure
      s3_bucket.objects({ prefix: prefix }).batch_delete!
    end

    test '.upload_folder initializes a FolderUpload and calls #upload with' do
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

              expected_bucket = expected_opts.delete(:bucket)
              given_bucket = given_opts.delete(:bucket)

              assert_equal [], given_args
              assert_hash_equal expected_opts, given_opts
              assert_equal expected_bucket.name, given_bucket.name
              assert_equal({ test_extra_opt: "test" }, upload_opts)
        end
      end
    end

    test '.object_if_exists returns false if the file is not uploaded' do
      with_temporary_bucket_path do |prefix|
        sample_files.each do |f|
          refute S3AssetManager.object_if_exists(File.basename(f), prefix)
        end
      end
    end

    test '.object_if_exists returns an Aws::S3::Object if the file is uploaded' do
      with_temporary_bucket_path do |prefix|
        S3AssetManager.
          upload_folder(sample_files_path, prefix: prefix, verbose: :silence)

        sample_files.each do |f|
          assert_instance_of(
            Aws::S3::Object,
            S3AssetManager.object_if_exists(File.basename(f), prefix)
          )
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
