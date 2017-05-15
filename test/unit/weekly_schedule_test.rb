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
    WeeklySchedule::DAYS.each{|d| weekly_schedule.public_send("#{d}=", true)}
    assert weekly_schedule.days == WeeklySchedule::DAYS
  end

  def test_partial_days
    weekly_schedule = WeeklySchedule.new
    weekly_schedule.monday = true
    assert weekly_schedule.days == ['monday']
  end

  def test_issue_id_presence
    weekly_schedule = WeeklySchedule.new
    assert weekly_schedule.invalid?
    assert_equal ['cannot be blank'], weekly_schedule.errors.messages[:issue_id]
  end

  def test_tracker_id_presence
    weekly_schedule = WeeklySchedule.new
    assert weekly_schedule.invalid?
    assert_equal ['cannot be blank'], weekly_schedule.errors.messages[:tracker_id]
  end

  def test_copy_has_new_issue
    assert default_issue.id != default_schedule.copy_issue.id
  end

  def test_copy_has_association
    default_issue.create_weekly_schedule
    copied_issue = default_schedule.copy_issue(:weekly_schedule)
    assert copied_issue.weekly_schedule.present?
    assert default_issue.weekly_schedule.id != copied_issue.weekly_schedule.id
  end

  def test_copy_has_same_subject
    assert default_issue.subject == default_schedule.copy_issue.subject
  end

  def test_copy_has_same_author
    assert default_issue.author_id == default_schedule.copy_issue.author_id
  end

  def test_execute
    default_schedule.execute
    assert default_schedule.last_try_at.present?
  end

  private

  def default_issue
    Issue.first
  end

  def default_schedule
    @default_schedule ||= WeeklySchedule.create(issue: default_issue, tracker_id: default_issue.tracker_id)
  end
end
