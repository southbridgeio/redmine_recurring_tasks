require File.expand_path('../../../test_helper', __FILE__)

class WeeklySchedulerSidebarHookTest < Redmine::IntegrationTest
  fixtures :projects,
           :users, :email_addresses,
           :roles,
           :members,
           :member_roles,
           :trackers,
           :projects_trackers,
           :enabled_modules,
           :issue_statuses,
           :issues,
           :enumerations,
           :custom_fields,
           :custom_values,
           :custom_fields_trackers,
           :attachments

  def setup
    Role.find(1).add_permission! :manage_schedule
    Role.find(1).add_permission! :view_schedule

    Redmine::Hook.clear_listeners
  end

  def teardown
    Redmine::Hook.clear_listeners
  end

  def test_hook_with_content_for_should_not_append_content
    Project.find(1).disable_module!(:redmine_recurring_tasks)
    log_user('jsmith', 'jsmith')
    get '/issues/1'

    assert_response :success
    assert_select '.weekly-scheduler', false
  end

  def test_hook_with_content_for_should_append_content
    Project.find(1).enable_module!(:redmine_recurring_tasks)
    Redmine::Hook.add_listener(WeeklySchedulerSidebarHook)

    log_user('jsmith', 'jsmith')
    get '/issues/1'

    assert_response :success
    assert_select '.redmine_recurring_tasks' do
      assert_select 'h3', text: I18n.t(:project_module_redmine_recurring_tasks)
    end
  end
end
