class WeeklySchedule < ActiveRecord::Base
  unloadable

  belongs_to :issue
  belongs_to :tracker

  validates :issue_id, presence: true, uniqueness: true
  validates :tracker_id, presence: true

  DAYS = %w(monday tuesday wednesday thursday friday saturday sunday).freeze

  # @return [Array<String>] array of days when schedule should be executed
  def days
    DAYS.select{|d| public_send(d)}
  end

  # @return [Issue] copied issue
  def copy_issue(associations = nil)
    new_issue = issue.deep_clone include: associations
    new_issue.init_journal(issue.author)
    unless issue.author.allowed_to?(:copy_issues, issue.project)
      fail "User #{issue.author.name} (##{issue.author.id}) unauthorized to copy issues"
    end
    new_issue.copy_from(issue, attachments: true, subtasks: true, link: false)
    new_issue.parent_issue_id = issue.parent_id
    new_issue.tracker_id = self.tracker_id
    new_issue.author_id = issue.author_id
    new_issue.save!
    new_issue
  end

  # @return [Boolean] boolean result of copy issue and save of schedule last try timestamp
  def execute(associations = nil)
    self.last_try_at = Time.now
    copy_issue(associations) && save
  end
end
