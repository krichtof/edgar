class AbilitationsController < ApplicationController
  before_filter :check_abilitation
  
  def check_abilitation
    unless current_account.manager?(current_user)
      redirect_to :back, notice: "Pas le droit"
    end
  end
  
  def new
    @abilitation = Abilitation.new
    @abilitation.build_user
    @abilitation.user.label_name = current_account.name    
  end
  
  def create
    user = User.find_by_email(params[:abilitation][:user_attributes][:email])
    if user
      params[:abilitation].delete(:user_attributes)
      params[:abilitation][:user_id] = user.id
    end
    
    @abilitation = current_account.abilitations.build(params[:abilitation])
    if @abilitation.save
      if user
        user.send_abilitation_notification(current_account, current_user)
        message = "#{user} peut désormais accéder au compte #{current_account}. Il vient d'être averti par mail."
      else
        # send_confirmation_instructions_with_abilitation
        @abilitation.user.send_abilitation_instructions(current_account, current_user)
        message = "Un mail vient d'être envoyé à l'adresse #{@abilitation.user.email}. Une fois que cette personne se sera enregistrée, elle pourra accéder au compte #{current_account}"
      end
      redirect_to edit_account_path, notice: message
    else
      redirect_to edit_account_path, alert: "#{@abilitation.user} a déjà accès au compte #{current_account} !"
    end
  end
  
  def update
    
  end
  
  def destroy
    abilitation = Abilitation.find(params[:id])
    if abilitation.destroy
      redirect_to edit_account_path, notice: "#{abilitation.user} ne peut plus accéder au compte #{current_account.name}"
    end    
  end
end
