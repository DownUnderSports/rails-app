module Libraries
  module S3AssetManagerTests
    class FolderUploadTest < ActiveSupport::TestCase
      def sample_files_path
        Rails.root.join('test', 'lib', 's3_asset_manager', 'sample_files').to_s
      end

      def sample_files
        Dir.glob("#{sample_files_path}/**/*")
      end

      def with_sample_upload(**opts)
        prefix = "folder_upload_testing_#{rand}"
        uploader =
          S3AssetManager::FolderUpload.
            new(
              folder_path: sample_files_path,
              bucket: s3_bucket,
              prefix: prefix,
              include_folder: false,
              **opts
            )
        yield uploader
      ensure
        uploader.
          s3_bucket.
          objects(prefix: prefix).
          batch_delete!
      end

      def assert_is_attr_reader(obj, meth, attr_name, value)
        assert obj.respond_to?(meth)
        assert_equal(
          obj.instance_variable_get(attr_name),
          obj.__send__(meth)
        )
        assert_equal value, obj.__send__(meth)
      end

      def assert_is_attr_accessor(obj, meth, attr_name, value)
        assert_is_attr_reader obj, meth, attr_name, value
        assert obj.respond_to?(:"#{meth}=")

        original_value = obj.__send__ meth
        new_value = "#{rand} value"
        obj.__send__ :"#{meth}=", new_value

        assert_is_attr_reader obj, meth, attr_name, new_value

        obj.__send__ :"#{meth}=", original_value
      end

      def refute_is_attr_accessor(meth)
        with_sample_upload do |sample_upload|
          refute sample_upload.respond_to?(:"#{meth}=")
        end
      end

      test '#initialize requires :folder_path and :bucket' do
        err = assert_raises(ArgumentError) do
          S3AssetManager::FolderUpload.new
        end
        assert_equal 'missing keywords: :folder_path, :bucket', err.message
      end

      test '#folder_path is an attr_reader' do
        with_sample_upload do |sample_upload|
          assert_is_attr_reader(
            sample_upload,
            :folder_path,
            :@folder_path,
            sample_files_path
          )

          refute_is_attr_accessor :folder_path
        end
      end

      test '#total_files is an attr_reader' do
        with_sample_upload do |sample_upload|
          assert_is_attr_reader sample_upload, :total_files, :@total_files, 5
          refute_is_attr_accessor :total_files
        end
      end

      test '#s3_bucket is an attr_reader' do
        with_sample_upload do |sample_upload|
          assert_is_attr_reader sample_upload, :s3_bucket, :@s3_bucket, s3_bucket
          refute_is_attr_accessor :s3_bucket
        end
      end

      test '#include_folder is an attr_reader' do
        with_sample_upload do |sample_upload|
          assert_is_attr_reader sample_upload, :include_folder, :@include_folder, false
          refute_is_attr_accessor :include_folder
        end
      end

      test '#prefix is an attr_reader' do
        prefix = "testing_#{rand}"
        with_sample_upload(prefix: prefix) do |sample_upload|
          assert_is_attr_reader sample_upload, :prefix, :@prefix, prefix
          refute_is_attr_accessor :prefix
        end
      end

      test '#files is an attr_accessor' do
        with_sample_upload do |sample_upload|
          assert_is_attr_accessor sample_upload, :files, :@files, sample_files
        end
      end

      test '#upload uploads all files from the given folder' do
        i = 0

        meth = Thread.method(:new)

        thread_created = ->(&block) do
          i += 1
          meth.call &block
        end

        expected_message = "Total files: 5... (folder #{sample_files_path} " \
                           "not included)\n"

        with_sample_upload do |sample_upload|
          assert_output(expected_message) do
            sample_upload.upload
          end
        end

        with_sample_upload do |sample_upload|
          Thread.stub(:new, thread_created) do
            sample_upload.s3_bucket.objects({prefix: sample_upload.prefix}).batch_delete!

            expected_messages = [ expected_message.strip ] |
              (1..5).map do |v|
                [
                  "[#{v}/5] uploading...",
                  "[#{v}/5] uploaded"
                ]
              end.flatten

            out, err = capture_io do
              sample_upload.upload verbose: true
            end

            out = out.split("\n").sort

            refute err.present?
            assert_equal expected_messages.sort, out
            assert_equal 11, out.size
          end

          assert_equal 5, i
          i = 0

          sample_files.each do |f|
            i += 1
            uploaded =
              S3AssetManager.
                object_if_exists(File.basename(f), sample_upload.prefix)

            assert_instance_of Aws::S3::Object, uploaded
          end

          assert_equal 5, i
        end
      end

      test '#upload prints nothing if verbose: :silence' do
        assert_output(nil) do
          with_sample_upload do |sample_upload|
            sample_upload.upload verbose: :silence
          end
        end
      end
    end
  end
end
