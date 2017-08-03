require File.expand_path('../../../../test_helper', __FILE__)

module RedmineRecurringTasks
  class IssueCheckerTest < ActiveSupport::TestCase
    fixtures :projects, :users, :email_addresses, :user_preferences, :members, :member_roles, :roles,
             :groups_users,
             :trackers, :projects_trackers,
             :enabled_modules,
             :versions,
             :issue_statuses, :issue_categories, :issue_relations, :workflows,
             :enumerations,
             :issues, :journals, :journal_details,
             :custom_fields, :custom_fields_projects, :custom_fields_trackers, :custom_values,
             :time_entries

    def test_schedules_return_schedule
      week_day = Time.now.strftime('%A').downcase

      schedule_hash = {
        issue_id: 1,
        tracker_id: 1,
        month_days: []
      }
      schedule_hash[week_day.to_sym] = true
      schedule = RecurringTask.new(schedule_hash)
      schedule.months = nil
      schedule.save!

      assert [schedule] == IssueChecker.new.schedules
    end

    def test_schedules_return_nothing_when_issue_deleted
      new_issue = Issue.new
      new_issue.copy_from(default_issue, attachments: true, subtasks: true, link: false)
      new_issue.save!

      weekly_schedule = RecurringTask.new(issue: new_issue, tracker_id: new_issue.tracker_id)
      RecurringTask::DAYS.each{|d| weekly_schedule.public_send("#{d}=", true)}
      weekly_schedule.save!

      new_issue.destroy!

      assert_equal [], IssueChecker.new.schedules
    end

    def test_schedules_return_nothing
      schedule_hash = {
        issue_id: 1,
        tracker_id: 1
      }
      RecurringTask.create!(schedule_hash)
      assert [] == IssueChecker.new.schedules
    end

    private

    def default_issue
      Issue.first
    end
  end
end
