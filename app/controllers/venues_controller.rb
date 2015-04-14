
class VenuesController < AppController
  include ApplicationHelper

  def index
    if params[:kind]
      @filtered_by = "(#{params[:kind]})"
      @contacts = Venue.joins(:structure => :contact).order(:name).by_type(params[:kind]).page params[:page]
    else
      @contacts = Venue.page params[:page]
    end
    respond_to do |format|
      format.html { render "contacts/index"}
      format.json { render json: @contacts }
    end
  end

  def show
    @venue = Venue.find(params[:id])
    add_asset(@venue.structure.contact)
    @structure = @venue.structure
    @main_person = @venue.main_person(current_user)
    @people = @venue.people
    @tasks = @venue.tasks
    @pending_tasks = @tasks.pending
    @completed_tasks = @tasks.completed
    @reportings = @venue.reportings
    @reporting = @venue.reportings.build
  end

  def new
    session[:return_to] = request.referer
    @venue = Venue.new
    @venue.build_structure
    @venue.structure.build_contact
    @venue.addresses.build
    @venue.rooms.build.capacities.build

    respond_to do |format|
      format.html
      format.json { render json: @venue }
    end
  end

  def edit
    @venue = Venue.find(params[:id])
    add_asset(@venue.structure.contact)
    @venue.schedulings.build(name: "Programmation Principale") unless @venue.schedulings.any?
    @venue.rooms.build(name:@venue.name).capacities.build unless @venue.rooms.any?
  end

  def create
    @venue = Venue.new(params[:venue])

    respond_to do |format|
      if @venue.save
        add_asset(@venue.structure.contact)
        format.html do
          if params[:commit] == t("helpers.submit.venue.create")
            redirect_to @venue, notice: t("activerecord.notices.models.venue.created", name: @venue.name)
          else
            redirect_to edit_venue_path(@venue), notice: t("activerecord.notices.models.venue.created", name: @venue.name)
          end
        end
        format.json { render json: @venue, status: :created, location: @venue }
      else
        @venue.addresses.build unless @venue.addresses.any?
        format.html { render action: "new" }
        format.json { render json: @venue.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @venue = Venue.find(params[:id])
    respond_to do |format|
      if @venue.update_attributes(params[:venue])
        format.html do
          session.delete(:return_to)
          redirect_to @venue, notice: t("activerecord.notices.models.venue.updated", name: @venue.name)
        end
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @venue.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @venue_id = params[:id]
    @venue = Venue.find(@venue_id)
    @venue.destroy

    respond_to do |format|
      format.html { redirect_to venues_url }
      format.js { render "destroy" }
    end
  end

end
