class RecurringTasksController < ApplicationController
  before_action :set_schedule, only: [:edit, :destroy, :update]
  before_action :set_issue
  before_action :check_permission

  def new
    existing_schedule = RecurringTask.find_by(issue: @issue)
    if existing_schedule
      return redirect_to edit_recurring_task_path(existing_schedule)
    end

    @schedule = RecurringTask.new(tracker: @issue.tracker, issue: @issue)
  end

  def create
    @schedule = RecurringTask.new
    @schedule.issue = @issue
    @schedule.assign_attributes(recurring_task_params)
    if @schedule.save
      redirect_to issue_path(@issue)
    else
      render :new
    end
  end

  def update
    @schedule.assign_attributes(recurring_task_params)
    if @schedule.save
      redirect_to issue_path(@issue)
    else
      render :edit
    end
  end

  def edit
  end

  def destroy
    @schedule.destroy
    redirect_to issue_path(@issue)
  end

  private

  def recurring_task_params
    params.require(:recurring_task).permit(:sunday, :monday, :tuesday, :wednesday,
                                           :thursday, :friday, :saturday, :time, :tracker_id, :client_run_type,
                                           months: [], month_days: [])
  end

  def set_schedule
    @schedule = RecurringTask.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def set_issue
    if @schedule.present?
      @issue = @schedule.issue
    else
      @issue = Issue.find(params[:issue_id])
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def check_permission
    unless User.current.allowed_to?(:manage_schedule, @issue.project)
      raise ::Unauthorized
    end
  end
end
