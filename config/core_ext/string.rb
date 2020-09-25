class String
  def pack_hex
    [self].pack_hex
  end

  def unpack_binary
    self.unpack("H*").first
  end
end
