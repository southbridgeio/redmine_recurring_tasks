namespace :redmine_recurring_tasks do
  desc 'Run issues check'
  task exec: :environment do
    date = Time.now
    week_day = date.strftime('%A').downcase

    WeeklySchedule.where("#{week_day} = true").find_each do |schedule|
      time_came = schedule.time.strftime('%H%M%S') <= date.strftime('%H%M%S')

      if time_came && (schedule.last_try_at.nil? || schedule.last_try_at.strftime('%Y%m%d') <= date.strftime('%Y%m%d'))
        begin
          issue = schedule.issue
          new_issue = Issue.new
          new_issue.init_journal(issue.author)
          unless issue.author.allowed_to?(:copy_issues, issue.project)
            fail "User #{issue.author.name} (##{issue.author.id}) unauthorized to copy issues"
          end
          new_issue.copy_from(issue, attachments: true, subtasks: true, link: false)
          new_issue.parent_issue_id = issue.parent_id
          new_issue.tracker_id = schedule.tracker_id
          new_issue.save!

          schedule.last_try_at = date
          schedule.save!
        rescue => e
          puts e.to_s
          puts e.backtrace.join("\n")
          next
        end
      end
    end
  end
end
