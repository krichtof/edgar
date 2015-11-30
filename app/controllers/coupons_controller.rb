class CouponsController < ApplicationController
  def new
    @coupon = Coupon.new
  end
  
  def create
    nb = params.delete(:nb_coupons).to_i
    nb.times { coupon = Coupon.create!(params["coupon"]) }
    redirect_to coupons_path
  end
  
  def edit
    
  end
  
  def update
    @coupon = Coupon.find(params[:id])
    p = {distributed: params[:distributed]}
    @coupon.update_attributes!(p)
  end
  
  def index
    @coupons = Coupon.where(distributed:false)
    @coupons = @coupons.where(event:params[:event]) if params[:event]
  end
end