# frozen_string_literal: true

class Object
  # == Constants ============================================================

  # == Attributes ===========================================================
  def self.redefined_method_tags
    @redefined_method_tags ||= Set.new
  end

  # == Extensions ===========================================================

  # == Boolean Class Methods ================================================

  # == Class Methods ========================================================
  def self.redefine_once(method_name, tag, &block)
    redefine_allowed =
      method_name.is_a?(Symbol) &&
      tag.is_a?(Symbol) &&
      redefined_method_tags.add?(tag)

    return false unless redefine_allowed
    alias_method tag, method_name
    define_method(method_name, &block)
  end

  # == Boolean Methods ======================================================

  # == Instance Methods =====================================================
  def yes_no_to_s
    !!self == self ? ThreeState.titleize(self) : to_s
  end

  def y_n_to_s
    !!self == self ? ThreeState.convert_value(self) : to_s
  end
end
