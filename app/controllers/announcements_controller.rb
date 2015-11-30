class AnnouncementsController < ApplicationController
  after_filter :set_last_hit_cookie
  def index
    @announcements = Announcement.where("published_at <= ?", Time.zone.now).limit(10).order("published_at DESC")
  end
  
  def set_last_hit_cookie
    cookies.permanent.signed[:last_hit] = Time.zone.now.to_i
  end
end