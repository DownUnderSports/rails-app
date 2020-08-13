require 'test_helper'

class CountryTest < ActiveSupport::TestCase
  def valid_attributes
    {
      person_id: person_fixtures(:athlete).id,
      sport_id: sport_fixtures(:anything).id,
      category: "athlete",
      year: Date.today.year,
      main: false,
      data: {}
    }
  end
end
