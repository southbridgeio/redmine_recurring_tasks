module RedmineRecurringTasks
  module Hooks
    # Issue sidebar hook for show weekly schedule on issue page
    class IssueViewHook < Redmine::Hook::ViewListener
      render_on :view_issues_show_description_bottom, partial: 'recurring_tasks/issues/bottom'
    end
  end
end
