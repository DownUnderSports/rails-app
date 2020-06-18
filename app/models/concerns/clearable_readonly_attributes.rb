# frozen_string_literal: true

module ClearableReadonlyAttributes
  extend ActiveSupport::Concern

  module ClassMethods
    def attr_not_readonly(*attributes)
      self._attr_readonly =
        (Set.new + (_attr_readonly || [])).subtract(attributes.map(&:to_s))
    end
  end
end
