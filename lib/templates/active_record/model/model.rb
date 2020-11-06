# encoding: utf-8
# frozen_string_literal: true

<% module_namespacing do -%>
# <%= class_name %> description
class <%= class_name %> < <%= parent_class_name.classify %>
  # == Constants ============================================================

  # == Attributes ===========================================================
<% if attributes.any?(&:password_digest?) -%>
  nacl_password
<% end -%>

  # == Extensions ===========================================================

  # == Attachments ==========================================================

  # == Relationships ========================================================
<% attributes.select(&:reference?).each do |attribute| -%>
  belongs_to :<%= attribute.name %><%= ", polymorphic: true" if attribute.polymorphic? %><%= ", required: true" if attribute.required? %>
<% end -%>

  # == Validations ==========================================================

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  # == Boolean Class Methods ================================================

  # == Class Methods ========================================================

  # == Boolean Methods ======================================================

  # == Instance Methods =====================================================

  # == Private Methods ======================================================

end
<% end -%>
