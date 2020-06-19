module WebpackerOverrides

  private
    def ignore_asset_errors
      @ignore_asset_errors
    end

    def ignore_asset_errors=(value)
      @ignore_asset_errors = CoerceBoolean.from(value)
    end

    def rescued_pack_tags
      @rescued_pack_tags ||= { }
    end

    def sources_from_manifest_entries(names, type:)
      names.map do |name|
        rescued_pack_tags[type] ||= {}
        unless (type == :stylesheet || ignore_asset_errors) && rescued_pack_tags[type][name]
          current_webpacker_instance.manifest.lookup!(name, type: type)
        end
      rescue
        raise unless type == :stylesheet
        rescued_pack_tags[type][name] = true
        nil
      end.flatten.select(&:present?)
    end
end
