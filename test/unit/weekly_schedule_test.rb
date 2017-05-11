require File.expand_path('../../test_helper', __FILE__)

class WeeklyScheduleTest < ActiveSupport::TestCase
  def test_full_days
    weekly_schedule = WeeklySchedule.new
    assert weekly_schedule.days, WeeklySchedule::DAYS
  end

  def test_partial_days
    weekly_schedule = WeeklySchedule.new
    weekly_schedule.monday = true
    assert weekly_schedule.days, WeeklySchedule::DAYS.dup.delete('monday')
  end
end
