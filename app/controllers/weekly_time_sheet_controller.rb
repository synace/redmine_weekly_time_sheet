class WeeklyTimeSheetController < ApplicationController
  unloadable
  layout 'base'
  helper :all
  
  def index
    @entries = entries_for(User.current, display_date)
    @entries_week = entries_for_week(User.current, display_first_day_of_week)
    @entry = TimeEntry.new(:spent_on => display_date)
  end
  
  def project_tasks
    ret = ''
    
    if Issue.respond_to?(:visible_by)
      Issue.visible_by(User.current) do
        ret = Issue.find(:all, :conditions => ["#{IssueStatus.table_name}.is_closed = ? AND #{Issue.table_name}.project_id = ?", false, params[:id]], :include => [:status, :project]).collect do |issue|
          "<option value=\"#{issue.id}\">#{issue.to_s}</option>"
        end.join("\n")
      end
    else
      ret = Issue.visible.open.find(:all, :conditions => {:project_id => params[:id]}).collect do |issue|
        "<option value=\"#{issue.id}\">#{issue.to_s}</option>"
      end.join("\n")
    end
      render :text => ret
  end
  
  def submit_time
    entry = TimeEntry.new(:user => User.current)
    unless params[:entry][:id].blank?
      entry = TimeEntry.find(params[:entry][:id])
    end
    
    if entry.update_attributes(params[:entry])
      render_entry_list(entry.spent_on)    
    else
      render :xml => entry.errors, :status => 403
    end
  end
  
  def delete_time
    entry = TimeEntry.find(params[:id])
    if entry.editable_by?(User.current)
      entry.destroy
    end
    render_entry_list(entry.spent_on)
  end
  
  def render_entry_list(date)
    @entries = entries_for(User.current, date)
    render :partial => 'entries'
  end

  helper_method :display_date, :display_first_day_of_week, :last_week, :next_week
  def display_date
    @display_date ||= if params[:day] and params[:month] and params[:year]
      Date.civil(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    else
      Date.today
    end
  end
  
  def display_first_day_of_week
    @display_first_day_of_week = begin
      days_to_subtract = (display_date.wday - 1) % 7
      display_date - days_to_subtract
    end
  end
  
  def last_week
    display_first_day_of_week - 7
  end
  
  def next_week
    display_first_day_of_week + 7
  end
  
  def entries_for(user, date)
    TimeEntry.find(:all, :conditions => {
      :spent_on => date,
      :user_id => user.id
    },
    :order => 'project_id, issue_id',
    :include => [:project, :issue])
  end

  def entries_for_week(user, date)
    TimeEntry.find(:all, :conditions => {
      :spent_on => [date, date+1, date+2, date+3, date+4, date+5, date+6],
      :user_id => user.id
    },
    :order => 'project_id, issue_id')
  end
end
