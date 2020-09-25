# require "tempfile"

module TarEncryptGun
  WORKING_ROOT = Rails.root.join("tmp", "encryption")

  class << self
    def encrypt(input, auth_data, output = nil)
      case get_file_path input
      in { dir: input_dir, name: input_name, path: input_path, sub_dir: _ }
        Rails.logger.debug { "extracted path: #{input_path}, #{input_name}" }
      end

      output ||= "#{input_path}.tar.nacl.gz"

      case get_file_path output, allow_empty: true
      in { dir: _, name: name, path: output_path, sub_dir: _ }
        Rails.logger.debug { "extracted path: #{output_path}, #{name}" }
      end

      case create_cipher  direction: :encrypt,
                          auth_data: (auth_data || input_path)
      in { cipher:, key:, iv:, auth_data: }
        Rails.logger.debug { "cipher created" }
      end

      open_tempfile(".tar") do |tarfile|
        %x{ bash -c "tar -cf \\"#{tarfile.path}\\" -C \\"#{input_dir}\\" \\"#{input_name}\\"" }

        compress_file cipher, tarfile, output_path
      end

      {
        key: key.unpack_binary,
        iv: iv.unpack_binary,
        auth_data: auth_data
      }
    end

    def decrypt(input:, key:, iv:, auth_data:, output: nil, chmod: nil)
      case get_file_path input
      in { dir: _, name: _, path: input_path, sub_dir: _ }
        Rails.logger.debug { "extracted path: #{input_path}" }
      end

      output ||= input_path.sub(".tar.nacl.gz", "")

      case get_file_path output, allow_empty: true
      in { dir: _, name: output_name, path: output_path, sub_dir: _ }
        Rails.logger.debug { "extracted path: #{output_path}" }
      end

      tmp_loc = WORKING_ROOT.join("decrypting", uniq_str, output_name)

      case get_file_path tmp_loc, allow_empty: true
      in { dir: tmp_dir, name: tmp_name, path: tmp_path, sub_dir: _ }
        Rails.logger.debug { "extracted path: #{tmp_path}" }
      end

      case create_cipher  direction: :decrypt,
                          key:       key.pack_hex,
                          iv:        iv.pack_hex,
                          auth_data: auth_data
      in { cipher:, key: _, iv: _, auth_data: _ }
        Rails.logger.debug { "cipher created" }
      end

      open_tempfile(".tar") do |tarfile|
        decompress_file cipher, tarfile, input_path

        tarfile.rewind

        FileUtils.mkdir_p tmp_dir
        %x{ bash -c "tar -xf \\"#{tarfile.path}\\" -C \\"#{tmp_dir}\\"" }
        FileUtils.mv tmp_path, output_path

        FileUtils.chmod chmod, output_path if chmod
      ensure
        FileUtils.rm_rf [ tmp_dir ], secure: true
      end

      output_path
    end

    private
      def open_tempfile(ext = rand.to_s)
        FileUtils.mkdir_p WORKING_ROOT

        file =
          Tempfile.open \
            [ uniq_str.gsub(/\./, ""), ext ],
            WORKING_ROOT,
            encoding: "ASCII-8BIT"

        begin
          yield file
        ensure
          file.close!
        end
      end

      def compress_file(cipher, file, path)
        Zlib::GzipWriter.open(path, Zlib::BEST_COMPRESSION) do |gz|
          gz.write(cipher.run(file.read.to_b64))
        end
      end

      def create_cipher(
                          direction:,
                          key:       nil,
                          iv:        nil,
                          auth_data: "#{rand}.nacl.auth"
                        )
        cipher           = Cipher.new
        cipher.direction = direction
        cipher.key       = key       ||= cipher.random_key
        cipher.iv        = iv        ||= cipher.random_iv
        cipher.auth_data = auth_data

        return { cipher: cipher, key: key, iv: iv, auth_data: auth_data }
      end

      def decompress_file(cipher, file, path)
        Zlib::GzipReader.open(path) do |gz|
          file.write(cipher.run(gz.read).from_b64)
        end
      end

      def uniq_str
        "#{rand}.#{Time.zone.now.to_i}"
      end

      def get_file_path(path, allow_empty: false)
        sub_dir = File.dirname(path).delete_prefix Rails.root.to_s
        sub_dir.delete_prefix! "/"

        directory = sub_dir.present? ? Rails.root.join(sub_dir) : Rails.root

        name = File.basename(path)
        full_path = directory.join(name)

        unless allow_empty || File.exist?(full_path)
          raise "File not found: #{name}"
        end

        return {
          dir:     directory.to_s,
          name:    name.to_s,
          path:    full_path.to_s,
          sub_dir: sub_dir.to_s
        }
      end
  end
end
