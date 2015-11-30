class StylesController < ApplicationController
  def index
    styles = Style.order(:style)
    styles = styles.where("lower(style) LIKE ?", "%#{params[:term].downcase}%") if params[:term].present?
    render json: styles.pluck(:style).to_json
  end
end