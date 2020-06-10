require "webpacker/helper"

module Webpacker::Helper
  # Computes the relative path for a given Webpacker image with the same automated processing as image_pack_tag.
  # Returns the relative path using manifest.json and passes it to path_to_asset helper.
  # This will use path_to_asset internally, so most of their behaviors will be the same.
  def image_pack_path(name)
    resolve_path_to_image(name)
  end
end
