class Agents::OrganisationsController < AgentAuthController
  respond_to :html, :json

  before_action :redirect_if_agent_incomplete, only: :index

  def index
    @organisations = policy_scope(Organisation)
    if @organisations.count == 1
      redirect_to organisation_agent_path(@organisations.first, current_agent)
    else
      render layout: 'registration'
    end
  end

  def show
    @organisation = policy_scope(Organisation).find(params[:id])
    @rdvs = @organisation.rdvs
    authorize(@organisation)
  end

  def edit
    @organisation = policy_scope(Organisation).find(params[:id])
    authorize(@organisation)
    respond_right_bar_with @organisation
  end

  def update
    @organisation = policy_scope(Organisation).find(params[:id])
    authorize(@organisation)
    flash[:notice] = "L'organisation a été modifiée." if @organisation.update(organisation_params)
    respond_right_bar_with @organisation, location: organisation_path(@organisation)
  end

  private

  def organisation_params
    params.require(:organisation).permit(:name, :horaires, :phone_number)
  end

  def redirect_if_agent_incomplete
    return unless agent_signed_in?

    redirect_to(new_agents_full_subscription_path) && return unless current_agent.complete?
  end
end
