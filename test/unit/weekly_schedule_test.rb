require File.expand_path('../../test_helper', __FILE__)

class WeeklyScheduleTest < ActiveSupport::TestCase
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

  def test_full_days
    weekly_schedule = WeeklySchedule.new
    assert weekly_schedule.days, WeeklySchedule::DAYS
  end

  def test_partial_days
    weekly_schedule = WeeklySchedule.new
    weekly_schedule.monday = true
    assert weekly_schedule.days, WeeklySchedule::DAYS.dup.delete('monday')
  end

  def test_copy_issue
    issue = Issue.first
    weekly_schedule = WeeklySchedule.create(issue: issue, tracker_id: issue.tracker_id)
    copied_issue = weekly_schedule.copy_issue
    assert true, issue.id != copied_issue.id
    assert true, issue.subject == copied_issue.subject
  end

  def test_execute
    issue = Issue.first
    weekly_schedule = WeeklySchedule.create(issue: issue, tracker_id: issue.tracker_id)
    weekly_schedule.execute
    assert true, weekly_schedule.last_try_at.present?
  end
end
