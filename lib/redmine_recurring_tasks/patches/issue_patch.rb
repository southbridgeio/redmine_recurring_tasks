module RedmineRecurringTasks
  module Patches
    # Patch to make link to RecurringTask
    module IssuePatch
      def self.included(base) # :nodoc:
        base.class_eval do
          

          has_one :recurring_task, dependent: :destroy

          # Return parent issue of children
          def recurring_task_root
            return recurring_task if recurring_task

            relation = IssueRelation.find_by(
              issue_to_id: id,
              relation_type: IssueRelation::TYPE_COPIED_TO
            )

            if relation
              RecurringTask.find_by(issue_id: relation.issue_from_id)
            else
              RecurringTask.joins(:issue).find_by(issues: { subject: subject,
                                                            project_id: project_id,
                                                            author_id: author_id })
            end
          end
        end
      end
    end
  end
end
Issue.send(:include, RedmineRecurringTasks::Patches::IssuePatch)
