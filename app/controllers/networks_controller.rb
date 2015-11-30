class NetworksController < ApplicationController
  def index
    networks = Network.order(:network)
    networks = networks.where("lower(network) LIKE ?", "%#{params[:term].downcase}%") if params[:term].present?
    render json: networks.pluck(:network).to_json
  end
end