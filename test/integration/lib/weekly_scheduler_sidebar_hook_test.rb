require File.expand_path('../../../test_helper', __FILE__)

class WeeklySchedulerSidebarHookTest < Redmine::IntegrationTest
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :trackers,
           :projects_trackers,
           :issue_statuses,
           :issues

  def setup
    Redmine::Hook.clear_listeners
  end

  def teardown
    Redmine::Hook.clear_listeners
  end

  def test_hook_with_content_for_should_not_append_content
    log_user('jsmith', 'jsmith')
    get '/issues/1'

    assert_response :success
    assert_select '.weekly-scheduler', false
  end

  def test_hook_with_content_for_should_append_content
    Role.find(1).add_permission! :manage_schedule
    Role.find(1).add_permission! :view_schedule
    Redmine::Hook.add_listener(WeeklySchedulerSidebarHook)

    log_user('jsmith', 'jsmith')
    get '/issues/1'

    assert_response :success
    assert_select '.weekly-scheduler' do
      assert_select 'h3', text: I18n.t(:project_module_weekly_scheduler)
    end
  end
end
