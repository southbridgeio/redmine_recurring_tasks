module RedmineRecurringTasks
  module Hooks
    # Issue sidebar hook for show weekly schedule on issue page
    class IssueSidebarHook < Redmine::Hook::ViewListener
      render_on :view_issues_sidebar_planning_bottom, partial: 'weekly_schedules/issues/sidebar'
    end
  end
end
