module RedmineRecurringTasks
  class IssueSidebarHook < Redmine::Hook::ViewListener
    render_on :view_issues_sidebar_planning_bottom, partial: 'weekly_schedules/issues/sidebar'
  end
end
