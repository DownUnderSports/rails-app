class Time
  include GlobalID::Identification

  alias :id :iso8601

  def self.find(time)
    case time
    when Time
      time.in_time_zone
    when Integer
      Time.zone.at(time)
    when String
      Time.zone.parse(time)
    else
      raise TypeError.new("passed value must be a Time, Integer, or String")
    end
  end
end
