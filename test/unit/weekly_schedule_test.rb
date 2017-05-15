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

  def test_copy_has_start_date
    assert default_issue.start_date != default_schedule.copy_issue.start_date
    assert default_schedule.copy_issue.start_date.present?
    assert default_schedule.copy_issue.start_date.today?
  end

  def test_copy_has_due_date
    assert default_issue.due_date != default_schedule.copy_issue.due_date
    assert default_schedule.copy_issue.due_date.present?
  end

  def test_copy_has_observer
    issue = Issue.find(1).deep_dup
    issue.add_watcher(User.find(1))
    issue.save!

    schedule = WeeklySchedule.create!(issue: issue, tracker: issue.tracker)
    copied_issue = schedule.copy_issue

    assert_equal issue.watchers.first.user, User.find(1)
    assert_equal copied_issue.watchers.size, issue.watchers.size
    assert_equal copied_issue.watchers.first.user, issue.watchers.first.user
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

  def test_copy_status_if_new
    issue = Issue.find(1)
    schedule = WeeklySchedule.create!(issue: issue, tracker: issue.tracker)
    copied_issue = schedule.copy_issue
    assert_equal issue.status_id, 1
    assert_equal copied_issue.status_id, 1
  end

  def test_copy_status_if_not_new
    issue = Issue.find(8)
    schedule = WeeklySchedule.create!(issue: issue, tracker: issue.tracker)
    copied_issue = schedule.copy_issue
    assert_equal issue.status_id, 5
    assert_equal copied_issue.status_id, 1
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
