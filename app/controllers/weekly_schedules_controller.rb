class WeeklySchedulesController < ApplicationController
  unloadable

  before_filter :set_schedule, only: [:edit, :destroy, :update]
  before_filter :set_issue
  before_filter :check_permission

  def new
    existing_schedule = WeeklySchedule.find_by(issue: @issue)
    if existing_schedule
      return redirect_to edit_weekly_schedule_path(existing_schedule)
    end

    @schedule = WeeklySchedule.new(tracker: @issue.tracker, issue: @issue)
  end

  def create
    @schedule = WeeklySchedule.new
    @schedule.issue = @issue
    @schedule.assign_attributes(weekly_schedule_params)
    if @schedule.save
      redirect_to issue_path(@issue)
    else
      render :new
    end
  end

  def update
    @schedule.assign_attributes(weekly_schedule_params)
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

  def weekly_schedule_params
    params.require(:weekly_schedule).permit(:sunday, :monday, :tuesday, :wednesday,
                                            :thursday, :friday, :saturday, :time, :tracker_id)
  end

  def set_schedule
    @schedule = WeeklySchedule.find(params[:id])
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
