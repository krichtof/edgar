class PeopleController < AppController
  include ApplicationHelper

  def index
    json = []
    if params[:term].present?
      @contacts = Contact.order(:name).where(contactable_type: "Person").where("lower(name) LIKE ?", "%#{params[:term].downcase}%")
      @contacts.each { |c| json.push({value:c.name, label:c.name, new: "false", avatar: c.avatar_url(:thumb)}) }

      unless @contacts.map(&:name).map(&:downcase).include?(params[:term].downcase)
        json.push({value:params[:term], label: "Créer la personne " + params[:term], new:"true"})
      end
    end
    render json: json
  end

  # GET /people/1
  # GET /people/1.json
  def show
    @person = Person.find(params[:id])
    add_asset(@person.contact)
    @tasks = @person.tasks
    @pending_tasks = @tasks.pending
    @completed_tasks = @tasks.completed
    @reportings = @person.reportings
    @reporting = @person.reportings.build

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @person }
    end
  end

  # GET /people/new
  # GET /people/new.json
  def new
    session[:return_to] = request.referer
    @person = Person.new
    @person.build_contact
    @person.name = params[:name] if params[:name].present?
    ps = @person.people_structures.build
    ps.structure = Structure.find(params[:structure_id]) if params[:structure_id]
    ps.structure = nil if !ps.structure.is_a? Structure

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @person }
    end
  end

  # GET /people/1/edit
  def edit
    @person = Person.find(params[:id])
    add_asset(@person.contact)
  end

  # POST /people
  # POST /people.json
  def create
    @person = Person.new(params[:person])

    respond_to do |format|
      if @person.save
        format.html { redirect_to @person, notice: t("activerecord.notices.models.person.created", name: @person) }
        format.json { render json: @person, status: :created, location: @person }
      else
        format.html { render action: "new" }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /people/1
  # PUT /people/1.json
  def update
    @person = Person.find(params[:id])

    respond_to do |format|
      if @person.update_attributes(params[:person])
        format.html { redirect_to @person, notice: t("activerecord.notices.models.person.updated", name: @person) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.json
  def destroy
    @person_id = params[:id]
    @person = Person.find(params[:id])
    @person.destroy

    respond_to do |format|
      format.html { redirect_to people_url }
      format.js
    end
  end
end
