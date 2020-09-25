# frozen_string_literal: true

class Array
  def pack_hex
    pack("H*")
  end

  def to_db_enum
    hashed = {}
    each {|v| hashed[v] = v.to_s}
    hashed
  end

  def to_model_enum
    hashed = {}
    each {|v| hashed[v.classify] = v.to_s}
    hashed
  end
end
