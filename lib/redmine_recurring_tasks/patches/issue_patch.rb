module RedmineRecurringTasks
  module Patches
    # Patch to make link to WeeklySchedule
    module IssuePatch
      def self.included(base) # :nodoc:
        base.class_eval do
          unloadable

          has_one :weekly_schedule, dependent: :destroy

          # Return parent issue of children
          def weekly_schedule_root
            return weekly_schedule if weekly_schedule.present?

            WeeklySchedule.joins(:issue).find_by(issues: {subject:    subject,
                                                          project_id: project_id,
                                                          author_id:  author_id})
          end
        end
      end
    end
  end
end
Issue.send(:include, RedmineRecurringTasks::Patches::IssuePatch)
