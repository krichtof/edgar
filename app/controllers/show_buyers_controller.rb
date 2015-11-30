
class ShowBuyersController < ApplicationController
  include ApplicationHelper
  
  def index
    if params[:kind]
      @filtered_by = "(#{params[:kind]})"
      @contacts = ShowBuyer.joins(:structure => :contact).order(:name).by_type(params[:kind]).page params[:page]
    else
      @contacts = ShowBuyer.page params[:page]
    end
    respond_to do |format|
      format.html { render "contacts/index"}
      format.json { render json: @contacts }
    end
  end

  # GET /venues/1
  # GET /venues/1.json
  def show
    @show_buyer = ShowBuyer.find(params[:id])
    add_asset(@show_buyer.structure.contact)
    @structure = @show_buyer.structure
    @main_person = @show_buyer.main_person(current_user)
    @people = @show_buyer.structure.people
    @tasks = @show_buyer.structure.tasks
    @pending_tasks = @tasks.pending
    @completed_tasks = @tasks.completed
    @reportings = @show_buyer.structure.reportings
    @reporting = @show_buyer.structure.reportings.build
  end

  # GET /venues/new
  # GET /venues/new.json
  def new
    session[:return_to] = request.referer
    @show_buyer = ShowBuyer.new
    @show_buyer.build_structure
    @show_buyer.structure.build_contact
    @show_buyer.addresses.build

    respond_to do |format|
      format.html
      format.json { render json: @venue }
    end
  end

  # GET /venues/1/edit
  def edit
    @show_buyer = ShowBuyer.find(params[:id])
    add_asset(@show_buyer.structure.contact)
    @show_buyer.schedulings.build(name: "Programmation") unless @show_buyer.schedulings.any?
  end

  # POST /venues
  # POST /venues.json
  def create
    @show_buyer = ShowBuyer.new(params[:venue])
    add_asset(@show_buyer.structure.contact)

    respond_to do |format|
      if @show_buyer.save
        format.html do
          if params[:commit] == t("helpers.submit.venue.create")
            redirect_to @show_buyer, notice: t("activerecord.notices.models.venue.created", name: @show_buyer.name)
          else
            redirect_to edit_show_buyer_path(@show_buyer), notice: t("activerecord.notices.models.show_buyer.created", name: @show_buyer.name)
          end
        end
        format.json { render json: @show_buyer, status: :created, location: @show_buyer }
      else
        @show_buyer.addresses.build unless @show_buyer.addresses.any?
        format.html { render action: "new" }
        format.json { render json: @show_buyer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /venues/1
  # PUT /venues/1.json
  def update
    @show_buyer = ShowBuyer.find(params[:id])
    respond_to do |format|
      if @show_buyer.update_attributes(params[:show_buyer])
        format.html do
          session.delete(:return_to)
          redirect_to @show_buyer, notice: t("activerecord.notices.models.show_buyer.updated", name: @show_buyer.name)
        end
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @show_buyer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /venues/1
  # DELETE /venues/1.json
  def destroy
    @show_buyer_id = params[:id]
    @show_buyer = ShowBuyer.find(@show_buyer_id)
    @show_buyer.destroy

    respond_to do |format|
      format.html { redirect_to show_buyers_url }
      format.js { render "destroy" }
    end
  end

end
