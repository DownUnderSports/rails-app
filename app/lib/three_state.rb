# encoding: utf-8
# frozen_string_literal: true

module ThreeState
  TITLECASE = {
    'Y' => 'Yes',
    'N' => 'No',
    'U' => 'Unknown',
  }.freeze

  def self.titleize(category)
    TITLECASE[convert_value(category)]
  end

  def self.convert_value(value)
    case value.to_s.downcase
    when /^(?:y|t(rue)?$)/
      'Y'
    when /^(?:n|f(alse)?$)/
      'N'
    else
      'U'
    end
  end

  module TableDefinition
    def three_state(*args, **opts)
      args.each do |name|
        column name, :three_state, **opts
      end
    end
  end

  class Type < CustomType
    def self.normalize_type_value(value)
      ThreeState.convert_value(value)
    end
  end
end