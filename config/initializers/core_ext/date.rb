# frozen_string_literal: true

class Date
  include GlobalID::Identification

  def month_name
    Date::MONTHNAMES[month]
  end

  alias_method :id, :to_s

  class << self
    alias_method :find, :parse
    alias_method :today, :current
  end
end
