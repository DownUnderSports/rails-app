require "active_support/concern"

module TestHelper
  module WebpackerStubs
    extend ActiveSupport::Concern

    def self.install
      Webpacker::Helper.include TestHelper::WebpackerStubs
    end

    class << self
      def skip_assets
        @skip_assets
      end

      def skip_assets=(value)
        @skip_assets = CoerceBoolean.from(value)
      end

      def with_skipped_assets(&block)
        Thread.exclusive {
          original = self.skip_assets
          begin
            self.skip_assets = true
            block.call
          ensure
            self.skip_assets = original
          end
        }
      end
    end

    private
      def skip_assets
        WebpackerStubs.skip_assets
      end

      def with_skipped_assets(&block)
        WebpackerStubs.with_skipped_assets(&block)
      end

      def rescued_pack_tags
        @rescued_pack_tags ||= { }
      end

      def sources_from_manifest_entries(names, type:)
        return [] if skip_assets

        names.map do |name|
          rescued_pack_tags[type] ||= {}
          unless (type == :stylesheet) && rescued_pack_tags[type][name]
            current_webpacker_instance.manifest.lookup!(name, type: type)
          end
        rescue
          raise unless type == :stylesheet
          rescued_pack_tags[type][name] = true
          nil
        end.flatten.select(&:present?)
      end
  end
end
