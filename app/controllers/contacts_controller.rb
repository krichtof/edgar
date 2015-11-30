class ContactsController < ApplicationController
  def bulk
    @contact_ids = params[:contact_ids]
    case params[:bulk_action]
    when "delete"
      Contact.where(id: params[:contact_ids]).find_each do |contact|
        unless contact.fine_model.destroy
          @error_message = "Une erreur est survenue lors de la suppression du contact #{contact.name}"
          render "bulk_error"
          return
        end
      end
      redirect_to contacts_path, notice: "Les contacts ont été supprimés"
    when "add_custom_tags"
      if params[:bulk_value].present?
        @contacts = Contact.where(id: params[:contact_ids])
        @contacts.each do |contact|
          contact.add_custom_tags(params[:bulk_value])
          unless contact.save
            @error_message = "Une erreur est survenue lors de la modificaton du contact #{contact.name}"
            render "bulk_error"
            return
          end
        end
        render "bulk_add_custom_tags"
      else
        @error_message = "Vous n'avez renseigné aucun tag personnalisé !"
        render "bulk_error"
      end
    end
  end

  def autocomplete
    contacts = Contact.order(:name).where("lower(contacts.name) LIKE ?", "%#{params[:term].downcase}%").limit(10)
    json=[]
    contacts.each do |c|
      fm = c.fine_model
      link = send(fm.class.name.underscore + "_path", fm)
      kind = I18n.t(fm.class.name.underscore, scope: "activerecord.models")
      json.push({value:c.name, label:c.name, new: "false", link: link, avatar: c.avatar_url(:thumb), kind: kind})
    end
    unless contacts.map(&:name).map(&:downcase).include?(params[:term].downcase)
      json.push({value:params[:term],
        label: "Créer la structure : " + params[:term], new:"true",
        link: new_structure_path(name: params[:term])
        })
      json.push({value:params[:term],
        label: "Créer la personne : " + params[:term], new:"true",
        link: new_person_path(name: params[:term])
        })
    end
    render json: json
  end

  def index
    if Contact.count == 0
      render "empty"
      return
    end

    if params[:address].present?
      radius = params[:radius].present? ? params[:radius] : 100
      addresses = Address.near(params[:address], radius, units: :km).where(account_id: Account.current_id)
    end

    if params[:commit] == "show map"
      addresses = Address.where(account_id: Account.current_id) unless addresses.present?
      contact_ids = Contact.advanced_search(params).pluck(:id)
      addresses = addresses.where(contact_id: contact_ids)
      @contacts_json = addresses.to_gmaps4rails do |address, marker|
        contact = address.contact
        marker.infowindow render_to_string(:partial => "contacts/infowindow_venue", :locals => { :contact => contact})
        marker.title   address.contact.name
      end if addresses.present?
      render "show_map"
    else
      @contacts = Contact.advanced_search(params)
      @contacts = @contacts.where(id: addresses.map(&:contact_id)) if addresses
      if params[:imported_at].present?
        @nb_imported_contacts, @nb_duplicates = ContactsImport.get_payload(params[:imported_at])
        @imported_at = params[:imported_at].to_i
        @test = @imported_at == current_account.test_imported_at
      end
      @contacts = @contacts.page params[:page]
      if params[:category].present?
        raise "Invalid Parameter" if %w(venues festivals show_buyers structures people).include?(params[:category]) == false
        @label_category = params[:category]
      end
    end
  end

  def show_map
    if params[:address].present?
      radius = params[:radius] || 100
      contacts = Address.where(account_id: Account.current_id).near(params[:address], radius, units: :km)
    else
      contacts = Address.where(account_id: Account.current_id)
    end
    @contacts_json = contacts.to_gmaps4rails do |address, marker|
      model = address.contact.fine_model
      marker.infowindow render_to_string(:partial => "contacts/infowindow_#{model.class.name.downcase}", :locals => { :model => model})
      marker.title   address.contact.name
    end if contacts.present?
  end

  def only
    @no_paging = false
    @contacts = case params[:filter]
      when "favorites" then current_user.favorites.page params[:page]
      when "contacted" then Contact.with_reportings.page params[:page]
      when "recently_created" then
        @no_paging = true
        Contact.send(params[:filter])
      when "recently_updated" then
        @no_paging = true
        Contact.send(params[:filter])
      when 'style' then
        @param_filter = params[:name]
        Kaminari.paginate_array(Contact.by_style(params[:name])).page params[:page]
      when 'network' then
        @param_filter = params[:name]
        Contact.by_network(params[:name]).page params[:page]
      when 'custom' then
        @param_filter = params[:name]
        Contact.by_custom(params[:name]).page params[:page]
      when 'contract' then
        @param_filter = params[:name]
        Kaminari.paginate_array(Contact.by_contract(params[:name])).page params[:page]
      when "dept" then
        @param_filter = params[:no]
        Contact.by_department(params[:no]).page params[:page]
      when "capacities_less_than" then
        @param_filter = params[:nb]
        Venue.capacities_less_than(params[:nb]).page params[:page]
      when "capacities_more_than" then
        @param_filter = params[:nb]
        Venue.capacities_more_than(params[:nb]).page params[:page]
      when "capacities_between" then
        @param_filter = [params[:nb1],params[:nb2]].join(" => ")
        Venue.capacities_between(params[:nb1],params[:nb2]).page params[:page]
      else
        redirect_to contacts_path
        return
    end
    @filtered_by = t(params[:filter], scope:"filters")
    render "index"
  end

  def add_to_favorites
    @contact = Contact.find(params[:id])
    if @contact
      current_user.add_to_favorites(@contact)
      if current_user.save
        render "add_to_favorites"
      end
    end
  end

  def remove_to_favorites
    @contact = Contact.find(params[:id])
    if @contact
      current_user.remove_to_favorites(@contact)
      if current_user.save
        render "remove_to_favorites"
      end
    end
  end
end
