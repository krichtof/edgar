class TagsController < ApplicationController
  def index
    type = params[:type]
    if type == "CustomTag"
      tags = Tag.where(type: params[:type], account_id: Account.current_id).map(&:name)
    else
      tags = Tag.where(name: params[:term], type: params[:type]).map(&:name)
    end
    render json: tags
  end
end
