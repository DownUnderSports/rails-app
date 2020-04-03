class GpgWrapper
  class HomeDir
    class << self
      def setup
        set_env_variables

        verify_agent_file setup_dir

        import_keys_if_needed
      end

      private
        def import_keys_if_needed
          creds = Rails.application.credentials
          gpg_keys = `GNUPGHOME=#{ENV['GNUPGHOME']} gpg -K`

          unless gpg_keys =~ /#{creds.dig(:gpg, :fingerprint)}/
            %x{
              bash -c "GNUPGHOME=#{ENV['GNUPGHOME']} gpg \\
                --pinentry-mode loopback \\
                --passphrase #{creds.dig(:gpg, :passphrase)} \\
                --import #{ENV['GNUPGHOME']}/no-reply.secret.key"
            }

            %x{
              bash -c \
              "echo #{creds.dig(:gpg, :fingerprint)}:6: | gpg --import-ownertrust"
            }
          end

          unless gpg_keys =~ /#{creds.dig(:gpg, :signing, :fingerprint)}/
            %x{
              bash -c "GNUPGHOME=#{ENV['GNUPGHOME']} gpg \\
                --import #{ENV['GNUPGHOME']}/no-reply.signing.secret.key"
            }
            %x{
              bash -c "echo #{creds.dig(:gpg, :signing, :fingerprint)}:5: \\
                | GNUPGHOME=#{ENV['GNUPGHOME']} gpg --import-ownertrust"
            }
          end
        end

        def set_env_variables
          ENV['GNUPGHOME'] = Rails.root.join('.gnupg').to_s
        end

        def setup_dir
          return false if Dir.exist?(`echo #{ENV['GNUPGHOME']}`.strip)

          puts 'NEEDS DIR'
          should_reload_agent = true

          AesEncryptDir.decrypt(
            input_path: Rails.root.join('.gnupg.tar.b64.aes.gz.b64'),
            **Rails.application.credentials.dig(:gpg, :directory)
          )

          true
        end

        def verify_agent_file(should_reload_agent = false)
          agent_file = "#{ENV['GNUPGHOME']}/gpg-agent.conf"
          if File.exist? agent_file
            if File.readlines(agent_file).grep(/allow-loopback-pinentry/).empty?
              should_reload_agent = true
              line_count = File.foreach(agent_file).inject(0) {|c, _l| c + 1 }
              File.open(agent_file, 'a') do |f|
                f.write "#{line_count.positive? ? "\n" : ''}allow-loopback-pinentry"
              end
            end
          else
            should_reload_agent = true
            File.open(agent_file, 'w') do |f|
              f.write 'allow-loopback-pinentry'
            end
          end

          if should_reload_agent
            puts 'RELOADING AGENT'
            `GNUPGHOME=#{ENV['GNUPGHOME']} gpg-connect-agent KILLAGENT /bye`
          end
        end
    end
  end
end
