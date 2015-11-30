class OpportunitiesController < ApplicationController
  before_filter :find_opportunity, except: [:index, :new, :create]

  def index
    @opportunities = Opportunity.all
    respond_to do |format|
      format.html
      format.json { render json: @opportunities }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @opportunity }
    end
  end

  def new
    @opportunity = Opportunity.new
    respond_to do |format|
      format.html
      format.json { render json: @opportunity }
    end
  end

  def edit
  end

  def create
    @opportunity = Opportunity.new(params[:opportunity])
    respond_to do |format|
      if @opportunity.save
        format.html { redirect_to @opportunity, notice: 'Opportunity was successfully created.' }
        format.json { render json: @opportunity, status: :created, location: @opportunity }
      else
        format.html { render action: "new" }
        format.json { render json: @opportunity.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @opportunity.update_attributes(params[:opportunity])
        format.html { redirect_to @opportunity, notice: 'Opportunity was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @opportunity.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @opportunity.destroy
    respond_to do |format|
      format.html { redirect_to opportunities_url }
      format.json { head :no_content }
    end
  end

  private
  
  def find_opportunity
    @opportunity = Opportunity.find(params[:id])
  end
end

