class AddressesController < ApplicationController
  def update
    address = Address.where(id: params[:id], account_id: Account.current_id).first
    if address
      address.latitude = params[:latitude]
      address.longitude = params[:longitude]
      address.admin_name1 = params[:admin_name1]
      address.admin_name2 = params[:admin_name2]
      address.geocoded_precisely = true
      if address.save
        render json: {lat:address.latitude, lng: address.longitude, yupee: "ok"}
      else
        render text: "fuck"
      end
    else
      render text: "fuck"
    end
  end
end