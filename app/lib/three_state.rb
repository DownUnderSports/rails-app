# encoding: utf-8
# frozen_string_literal: true

class ThreeState
  YES = "Y".freeze
  NO = "N".freeze
  UNKNOWN = "U".freeze

  TITLECASE = {
    YES => "Yes".freeze,
    NO => "No".freeze,
    UNKNOWN => "Unknown".freeze,
  }.freeze

  class Value
    def titleize
      TITLECASE[self.value]
    end

    def to_str
      self.value
    end
    alias :to_s :to_str
    alias :as_json :to_str

    def ==(comp)
      to_str == comp
    end
    alias :eql? :==


    alias :is_class? :===
    def ===(comp)
      is_class?(comp) ||
      self.==(ThreeState.convert_value(comp))
    end

    def to_boolean
      self.to_bool
    end
  end

  class UnknownState < ThreeState::Value
    def value
      UNKNOWN
    end

    def to_bool
      nil
    end
  end

  class YesState < ThreeState::Value
    def value
      YES
    end

    def to_bool
      true
    end
  end

  class NoState < ThreeState::Value
    def value
      NO
    end

    def to_bool
      false
    end
  end

  def self.titleize(category)
    convert_value(category).titleize
  end

  def self.convert_value(value)
    case value
    when ThreeState::Value
      value
    when nil, ""
      UnknownState.new
    else
      case value.to_s
      when /^(?:y(es)?|t(rue)?)$/i
        YesState.new
      when /^(?:no?|f(alse)?)$/i
        NoState.new
      else
        UnknownState.new
      end
    end
  end

  module TableDefinition
    def three_state(*args, **opts)
      args.each do |name|
        column name, :three_state, **opts
      end
    end
  end

  class Type < PsqlDomainType
    def self.normalize_type_value(value)
      ThreeState.convert_value(value)
    end

    def self.serialize(value)
      normalize_type_value(value).value
    end
  end
end
