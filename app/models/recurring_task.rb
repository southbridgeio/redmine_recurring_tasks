class RecurringTask < ActiveRecord::Base
  UnauthorizedError = Class.new(StandardError)

  belongs_to :issue
  belongs_to :tracker

  validates :issue_id,    presence: true, uniqueness: true
  validates :tracker_id,  presence: true

  validates :time, presence: true

  DAYS = %w(monday tuesday wednesday thursday friday saturday sunday).freeze

  RUN_TYPE_W_DAYS = :week_days
  RUN_TYPE_M_DAYS = :month_days

  attr_accessor :client_run_type

  before_save do
    if client_run_type.present?
      if client_run_type == RUN_TYPE_M_DAYS.to_s
        DAYS.each{|d| public_send("#{d}=", false)}
      else
        self.month_days = []
      end
    end
  end

  # @return [Array<String>] array of days when schedule should be executed
  def days
    DAYS.select{|d| public_send(d)}
  end

  def months=(value)
    value ||= default_months
    super(value.to_json)
  end

  def months
    result = super
    JSON.parse(result)
  rescue
    raise result
  end

  def month_days=(value)
    value ||= default_month_days
    super(value.to_json)
  end

  def time=(value)
    value = Time.new(*value.values) if value.is_a?(Hash)

    return super(value.to_time) unless value.respond_to?(:utc)
    super(value.dup.utc)
  end

  def time
    super&.localtime
  end

  def month_days
    result = super
    result = JSON.parse(result)
  rescue
    raise result
  end

  def month_days_parsed
    month_days.map{|x| x == 'last_day' ? Time.now.end_of_month.day.to_s : x}.compact.uniq
  end

  def self.schedules(current_time = Time.now)
    week_day  = current_time.strftime('%A').downcase
    month_day = current_time.day

    # months
    scope = where("months LIKE '%\"#{current_time.month.to_s}\"%'")

    scope.select do |schedule|
      if schedule.month_days.empty?
        # week day
        next unless schedule.public_send(week_day)
      else
        # month day
        month_days = schedule.month_days_parsed
        next unless month_days.include?(month_day.to_s)
      end

      # time
      schedule.time_came?(current_time)
    end
  end

  # @return [Issue] copied issue
  def copy_issue(associations = [])
    return if issue.project.archived? || issue.project.closed?

    settings = Setting.find_by(name: :plugin_redmine_recurring_tasks)&.value || {}

    issue.deep_clone(include: associations, except: %i[parent_id root_id lft rgt created_on updated_on closed_on]) do |original, copy|
      case original
      when Issue
        copy.init_journal(original.author)
        new_author =
          if settings['use_anonymous_user']
            User.anonymous
          else
            unless original.author.allowed_to?(:copy_issues, issue.project)
              raise UnauthorizedError, "User #{original.author.name} (##{original.author.id}) unauthorized to copy issues"
            end
            original.author
          end
        copy.custom_field_values = original.custom_field_values.inject({}) { |h, v| h[v.custom_field_id] = v.value; h }
        copy.author_id = new_author.id
        copy.tracker_id = original.tracker_id
        copy.parent_issue_id = original.parent_id
        copy.status_id =
          case settings['copied_issue_status']
          when nil
            copy.new_statuses_allowed_to(original.author).sort_by(&:position).first&.id
          when '0'
            original.status_id
          else
            settings['copied_issue_status']
          end
        copy.attachments = original.attachments.map do |attachement|
          attachement.copy(container: original)
        end
        copy.watcher_user_ids = original.watcher_users.select { |u| u.status == User::STATUS_ACTIVE }.map(&:id)

        copy.start_date = Time.now

        if original.due_date.present?
          issue_date = (original.start_date || original.created_on).to_date
          copy.due_date = copy.start_date + (original.due_date - issue_date)
        end
      else
        next
      end
    end.tap(&:save!)
  end

  # @return [Boolean] boolean result of copy issue and save of schedule last try timestamp
  def execute(associations = nil)
    self.last_try_at = Time.now
    copy_issue(associations) && save
  end

  # @return [Symbol] return :month_days if any month days are present, else :week_days
  def run_type
    self.month_days.any? ? RUN_TYPE_M_DAYS : RUN_TYPE_W_DAYS
  end

  def time_came?(current_time = Time.now)
    utc_offset = current_time.utc_offset / 60 / 60
    utc_offset -= 1 if time.in_time_zone(utc_offset).dst?
    time.in_time_zone(utc_offset).strftime('%H%M%S').to_i <= current_time.strftime('%H%M%S').to_i &&
      (last_try_at.nil? || last_try_at.in_time_zone(utc_offset).strftime('%Y%m%d').to_i < current_time.strftime('%Y%m%d').to_i)
  end

  private

  def default_month_days
    []
  end

  def default_months
    (1..12).to_a.map(&:to_s)
  end
end
