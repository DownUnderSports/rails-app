class DateHelperTest < ActionView::TestCase
  def zellers_rule(date)
    k = date.day
    m = date.month - 2
    y = date.year
    if m < 1
      m += 12
      y -= 1
    end
    century = y / 100
    y = y.to_s[-2..-1].to_i

    f = (k + ((13 * m - 1) / 5) + y + (y / 4) + (century / 4) - (2 * century)) % 7
    f += 7 if f < 1
    f - 1
  end

  test "#monday returns a date" do
    assert_instance_of Date, monday
  end

  test "#monday returns the monday during the week of the given date" do
    # known dates
    [
      [Date.new(2020, 2, 29), Date.new(2020, 2, 24)],
      [Date.new(2020, 3, 1), Date.new(2020, 2, 24)],
      [Date.new(2020, 3, 2), Date.new(2020, 3, 2)],
      [Date.new(2020, 3, 12), Date.new(2020, 3, 9)],
      [Date.new(2020, 3, 15), Date.new(2020, 3, 9)],
      [Date.new(2020, 3, 16), Date.new(2020, 3, 16)],
      [Date.new(2020, 3, 16), Date.new(2020, 3, 16)],
    ].each do |entered, expected|
      assert_equal expected, monday(entered)
      assert_equal (entered - zellers_rule(entered)), monday(entered)
    end

    # randomize for extra safety
    10.times do
      date = Date.today + rand(100)
      assert_equal (date - zellers_rule(date)), monday(date)
    end
  end

  test "#monday with no arguments returns the monday of this week" do
    assert_equal (Date.today - zellers_rule(Date.today)), monday
  end

  test "#last_monday returns #monday minus 7 days" do
    assert_equal monday - 7, last_monday
    stub(:monday, 0) do
      assert_equal -7, last_monday
    end
  end

end
