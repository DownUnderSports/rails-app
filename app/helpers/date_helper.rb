module DateHelper
  def monday(date = Time.zone.today)
    Date.commercial date.end_of_week.year, date.cweek
  end

  def last_monday
    monday - 7
  end
end
