class CampaignsController < ApplicationController
  before_filter :find_campaign, except: [:index, :new, :create]

  def index
    @campaigns = Campaign.all
    respond_to do |format|
      format.html
      format.json { render json: @campaigns }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @campaign }
    end
  end

  def new
    @campaign = Campaign.new
    respond_to do |format|
      format.html
      format.json { render json: @campaign }
    end
  end

  def edit
  end

  def create
    @campaign = Campaign.new(params[:campaign])
    respond_to do |format|
      if @campaign.save
        format.html { redirect_to @campaign, notice: 'Campaign was successfully created.' }
        format.json { render json: @campaign, status: :created, location: @campaign }
      else
        format.html { render action: "new" }
        format.json { render json: @campaign.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @campaign.update_attributes(params[:campaign])
        format.html { redirect_to @campaign, notice: 'Campaign was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @campaign.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @campaign.destroy
    respond_to do |format|
      format.html { redirect_to campaigns_url }
      format.json { head :no_content }
    end
  end

  private

  def find_campaign
    @campaign = Campaign.find(params[:id])
  end
end

