class StreamCSVDeflator
  def initialize(enum)
    @enum = enum
    @deflator = Zlib::Deflate.new
  end

  def y
    @enum
  end

  def stream(row)
    y << @deflator.deflate(CSV.generate_line(row, force_quotes: true, encoding: 'utf-8'), Zlib::SYNC_FLUSH)
  end

  def close
    y << @deflator.flush(Zlib::FINISH)
  end
end
