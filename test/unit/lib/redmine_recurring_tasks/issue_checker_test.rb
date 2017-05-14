require File.expand_path('../../../../test_helper', __FILE__)

module RedmineRecurringTasks
  class IssueCheckerTest < ActiveSupport::TestCase
    def test_schedules_return_schedule
      week_day = Time.now.strftime('%A').downcase

      schedule_hash = {
        issue_id: 1,
        tracker_id: 1,
      }
      schedule_hash[week_day.to_sym] = true
      schedule = WeeklySchedule.create!(schedule_hash)
      assert [schedule], IssueChecker.schedules
    end

    def test_schedules_return_nothing
      schedule_hash = {
        issue_id: 1,
        tracker_id: 1
      }
      WeeklySchedule.create!(schedule_hash)
      assert [], IssueChecker.schedules
    end
  end
end
