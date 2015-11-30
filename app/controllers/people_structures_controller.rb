class PeopleStructuresController < ApplicationController
  def create
    structure = Structure.find(params[:structure_id])
    person_contact = Contact.where(contactable_type: "Person").where("lower(name) LIKE ?", "%#{params[:person_name].downcase}%").first if params[:person_name].present?
    if person_contact
      @people_structure = structure.people_structures.build
      @people_structure.person = person_contact.fine_model
      @people_structure.title = params[:function] if params[:function].present?
      if @people_structure.save
        render "create"
      else
        render "errors"
      end
    else
      render js: "window.location = '#{new_structure_person_path(structure, name: params[:person_name], title: params[:function])}'"
    end
  end
end