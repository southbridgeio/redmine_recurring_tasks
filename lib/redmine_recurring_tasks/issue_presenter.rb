module RedmineRecurringTasks
  class IssuePresenter < SimpleDelegator
    include RecurringTasksHelper
    include Rails.application.routes.url_helpers

    def schedule
      return '' if recurring_task.blank?

      if recurring_task_root.run_type == RecurringTask::RUN_TYPE_M_DAYS
        return "#{recurring_task_root.month_days_parsed.join(', ')} #{recurring_task_root.months.map { |m| I18n.t('date.month_names')[m.to_i] }.join(', ')} — #{recurring_task_root.time.to_s(:time)}"
      end

      days = @issue.recurring_task_root.days.map do |field|
        <<-HTML
          <li>
            #{RecurringTask.human_attribute_name(field)}, #{recurring_task_root.time.to_s(:time)}
          </li>
        HTML
      end

      result =
        <<-HTML
          <ul>
            #{days.join}
          </ul>
        HTML
      result.html_safe
    end

    def schedule_template
      return '' if recurring_task_root.issue == __getobj__

      result =
        <<-HTML
          <div>
            #{I18n.t(:template)}:
            #{ActionController::Base.helpers.link_to("#{recurring_task_root.issue.subject.truncate(60)} ##{recurring_task_root.issue.id}", issue_path(recurring_task_root.issue))}
          </div>
        HTML
      result.html_safe
    end
  end
end
