# encoding: utf-8
# frozen_string_literal: true

module S3AssetManager
  class << self
    def s3_bucket
      return @s3_bucket if @s3_bucket

      require "aws-sdk-s3"

      Aws.config.update({
        region: Rails.application.credentials.dig(:aws, :region),
        credentials:
          Aws::Credentials.new(
            Rails.application.credentials.dig(:aws, :access_key_id),
            Rails.application.credentials.dig(:aws, :secret_access_key)
          ),
      })

      @s3_bucket = Aws::S3::Resource.new.bucket("#{Rails.application.credentials.dig(:aws, :bucket_name)}-#{(Rails.env.to_s.presence || "development").downcase}")
    end
  end

  def self.upload_folder(folder_path, include_folder: false, bucket: nil, prefix: "", **opts)
    self::FolderUpload.new(folder_path: folder_path, bucket: bucket || s3_bucket, include_folder: CoerceBoolean.from(include_folder), prefix: prefix).upload **opts
  end

  def self.object_if_exists(file_path, asset_prefix = "")
    o =
      s3_bucket.
      object("#{asset_prefix.presence && "#{asset_prefix}/"}#{file_path}")

    o.exists? && o
  end

  def self.save_tmp_csv(file_name, data = nil)
    if data.nil?
      data, file_name = file_name, "temp-download.csv"
    end
    save_tmp_file file_name, data
  end

  def self.save_tmp_file(file_name, body)
    save_to_s3 "tmp/#{file_name}", body
  end

  def self.save_to_s3(object_path, body)
    [ object_path, s3_bucket.object(object_path).put( body: body ) ]
  end

  def self.download_tmp_file(file_name = nil, **opts, &block)
    file_name = "temp-download.csv" unless file_name.present?
    dir = Rails.root.join("tmp", "s3_downloads", "#{rand(100)}.#{Time.now.to_i}")
    path = dir.join(file_name)

    FileUtils.mkdir_p dir

    s3_bucket.object("tmp/#{file_name}").download_file path

    if block_given?
      begin
        File.open(path, **opts, &block)
      ensure
        FileUtils.rm_rf [ dir ], secure: true
      end
    else
      path
    end
  end
end
