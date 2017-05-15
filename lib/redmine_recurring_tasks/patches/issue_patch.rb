module RedmineRecurringTasks
  module Patches
    # Patch to make link to WeeklySchedule
    module IssuePatch
      def self.included(base) # :nodoc:
        base.class_eval do
          unloadable

          has_one :weekly_schedule, dependent: :destroy
        end
      end
    end
  end
end
Issue.send(:include, RedmineRecurringTasks::Patches::IssuePatch)
