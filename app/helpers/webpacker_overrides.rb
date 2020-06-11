module WebpackerOverrides
  private
    def rescued_pack_tags
      @rescued_pack_tags ||= {}
    end

    def sources_from_manifest_entries(names, type:)
      names.map do |name|
        current_webpacker_instance.manifest.lookup!(name, type: type) unless rescued_pack_tags[name]
      rescue
        rescued_pack_tags[name] = true
        nil
      end.flatten.select(&:present?)
    end
end
