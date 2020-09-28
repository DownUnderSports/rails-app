ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  html_tag.sub(/\s+class="([^"]+)"/, %q{ class="\1 has-error"}).html_safe
end
