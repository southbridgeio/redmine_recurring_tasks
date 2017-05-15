require File.expand_path('../../../../test_helper', __FILE__)

module RedmineRecurringTasks
  class IssueCheckerTest < ActiveSupport::TestCase
    def test_schedules_return_schedule
      week_day = Time.now.strftime('%A').downcase

      schedule_hash = {
        issue_id: 1,
        tracker_id: 1
      }
      schedule_hash[week_day.to_sym] = true
      schedule = WeeklySchedule.create!(schedule_hash)
      assert [schedule] == IssueChecker.schedules
    end

    def test_schedules_return_nothing_when_issue_deleted
      new_issue = Issue.new
      new_issue.copy_from(default_issue, attachments: true, subtasks: true, link: false)
      new_issue.save!

      weekly_schedule = WeeklySchedule.new(issue: new_issue, tracker_id: new_issue.tracker_id)
      WeeklySchedule::DAYS.each{|d| weekly_schedule.public_send("#{d}=", true)}
      weekly_schedule.save!

      new_issue.destroy!

      assert_equal [], IssueChecker.schedules
    end

    def test_schedules_return_nothing
      schedule_hash = {
        issue_id: 1,
        tracker_id: 1
      }
      WeeklySchedule.create!(schedule_hash)
      assert [] == IssueChecker.schedules
    end

    private

    def default_issue
      Issue.first
    end
  end
end
