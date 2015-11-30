class CustomsController < ApplicationController
  def index
    customs = Custom.order(:custom)
    customs = customs.where("lower(custom) LIKE ?", "%#{params[:term].downcase}%") if params[:term].present?
    render json: customs.pluck(:custom).to_json
  end
end