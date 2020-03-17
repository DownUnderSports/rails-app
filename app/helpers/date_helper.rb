module DateHelper
  def monday(date = Date.today)
    Date.commercial date.end_of_week.year, date.cweek
  end

  def last_monday
    monday - 7
  end
end
