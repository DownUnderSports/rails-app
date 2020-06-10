# encoding: utf-8
# frozen_string_literal: true

class PsqlDomainType < ActiveRecord::Type::Value
  class ImplementationError < StandardError
  end

  def self.normalize_type_value(_)
    raise ImplementationError.new("Method Not Implemented")
  end

  def self.cast(value)
    self.normalize_type_value(value)
  end

  def self.deserialize(value)
    self.normalize_type_value(value)
  end

  def self.serialize(value)
    self.normalize_type_value(value)
  end

  def cast(value)
    super self.class.cast(value)
  end

  def deserialize(value)
    super self.class.deserialize(value)
  end

  def serialize(value)
    super self.class.serialize(value)
  end

  private
    def normalize_type_value(value)
      self.class.normalize_type_value(value)
    end
end
