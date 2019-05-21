require File.expand_path('../../test_helper', __FILE__)

class RecurringTaskTest < ActiveSupport::TestCase
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
    recurring_task = RecurringTask.new
    RecurringTask::DAYS.each{|d| recurring_task.public_send("#{d}=", true)}
    assert recurring_task.days == RecurringTask::DAYS
  end

  def test_partial_days
    recurring_task = RecurringTask.new
    recurring_task.monday = true
    assert recurring_task.days == ['monday']
  end

  def test_issue_id_presence
    recurring_task = RecurringTask.new
    assert recurring_task.invalid?
    assert_equal ['cannot be blank'], recurring_task.errors.messages[:issue_id]
  end

  def test_tracker_id_presence
    recurring_task = RecurringTask.new
    assert recurring_task.invalid?
    assert_equal ['cannot be blank'], recurring_task.errors.messages[:tracker_id]
  end

  def test_copy_has_start_date
    assert default_issue.start_date != default_schedule.copy_issue.start_date
    assert default_schedule.copy_issue.start_date.present?
  end

  def test_copy_has_due_date
    assert default_issue.due_date != default_schedule.copy_issue.due_date
    assert default_schedule.copy_issue.due_date.present?
  end

  def test_copy_has_observer
    issue = Issue.find(1).deep_dup
    issue.add_watcher(User.find(1))
    issue.save!

    schedule = RecurringTask.create!(issue: issue, tracker: issue.tracker)
    copied_issue = schedule.copy_issue

    assert_equal issue.watchers.first.user, User.find(1)
    assert_equal copied_issue.watchers.size, issue.watchers.size
    assert_equal copied_issue.watchers.first.user, issue.watchers.first.user
  end

  def test_copy_has_new_issue
    assert default_issue.id != default_schedule.copy_issue.id
  end

  def test_copy_has_association
    default_issue.create_recurring_task
    copied_issue = default_schedule.copy_issue(:recurring_task)
    assert copied_issue.recurring_task.present?
    assert default_issue.recurring_task.id != copied_issue.recurring_task.id
  end

  def test_copy_status_if_new
    issue = Issue.find(1)
    schedule = RecurringTask.create!(issue: issue, tracker: issue.tracker)
    copied_issue = schedule.copy_issue
    assert_equal issue.status_id, 1
    assert_equal copied_issue.status_id, 1
  end

  def test_copy_status_if_not_new
    issue = Issue.find(8)
    schedule = RecurringTask.create!(issue: issue, tracker: issue.tracker)
    copied_issue = schedule.copy_issue
    assert_equal issue.status_id, 5
    assert_equal copied_issue.status_id, 1
  end

  def test_copy_has_same_subject
    assert default_issue.subject == default_schedule.copy_issue.subject
  end

  def test_copy_has_same_author_when_anonymous_user_not_used
    Setting.plugin_redmine_recurring_tasks = { 'use_anonymous_user' => nil }
    assert default_issue.author_id == default_schedule.copy_issue.author_id
  end

  def test_copy_has_anonymous_author_when_anonymous_user_used
    Setting.plugin_redmine_recurring_tasks = { 'use_anonymous_user' => 1 }
    assert default_schedule.copy_issue.author_id == User.anonymous.id
  end

  def test_copy_when_project_is_closed
    assert closed_project_schedule.copy_issue.nil?
  end

  def test_copy_when_project_is_archived
    assert archived_project_schedule.copy_issue.nil?
  end

  def test_execute
    default_schedule.execute
    assert default_schedule.last_try_at.present?
  end

  def test_month_days
    days = %w(1 2 3)
    default_schedule.month_days = days
    assert default_schedule.save
    assert default_schedule.month_days == days
  end

  def test_run_type_m
    default_schedule.month_days = %w(1 2 3)
    assert default_schedule.save
    assert default_schedule.run_type == RecurringTask::RUN_TYPE_M_DAYS
  end

  def test_run_type_w
    default_schedule.month_days = []
    assert default_schedule.save
    assert default_schedule.run_type == RecurringTask::RUN_TYPE_W_DAYS
  end

  def test_months
    days = %w(1 2 3)
    default_schedule.month_days = days
    assert default_schedule.save
    assert default_schedule.month_days == days
  end

  def test_month_days
    days = %w(last_day)
    default_schedule.month_days = days
    assert default_schedule.save
    assert default_schedule.month_days == days
  end

  def test_month_days_parsed
    days = %w(last_day)
    default_schedule.month_days = days
    assert default_schedule.save
    assert default_schedule.month_days_parsed == [Time.now.end_of_month.day.to_s]
  end

  def test_time_came
    current_time = Time.parse('10:00:00')
    schedule = RecurringTask.new(time: current_time)
    assert schedule.time_came?(current_time)
    assert schedule.time_came?(current_time + 1.minute)
    refute schedule.time_came?(current_time - 1.minute)
    refute schedule.time_came?(current_time + 14.hours)
  end

  def test_time_came_if_last_try_at_is_earlier_than_current_day
    current_time = Time.parse('00:00:00')
    last_try_at = current_time - 1.day
    schedule = RecurringTask.new(time: current_time, last_try_at: last_try_at)
    assert schedule.time_came?(current_time)
  end

  def test_time_came_if_last_try_at_day_is_equal_to_current_day
    current_time = Time.parse('00:00:00')
    last_try_at = current_time + 1.minute
    schedule = RecurringTask.new(time: current_time, last_try_at: last_try_at)
    refute schedule.time_came?(current_time)
  end

  def test_time_came_if_last_try_at_day_is_later_than_current_day
    current_time = Time.parse('00:00:00')
    last_try_at = current_time + 1.day
    schedule = RecurringTask.new(time: current_time, last_try_at: last_try_at)
    refute schedule.time_came?(current_time)
  end

  private

  def default_issue
    Issue.first
  end

  def default_schedule
    @default_schedule ||= RecurringTask.create(issue: default_issue, tracker_id: default_issue.tracker_id)
  end

  def closed_project_schedule
    project = Project.new
    project.status = Project::STATUS_CLOSED
    RecurringTask.new(issue: Issue.new(project: project))
  end

  def archived_project_schedule
    project = Project.new
    project.status = Project::STATUS_ARCHIVED
    RecurringTask.new(issue: Issue.new(project: project))
  end
end
