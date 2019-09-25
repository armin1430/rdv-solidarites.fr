class Organisations::UsersController < DashboardAuthController
  respond_to :html, :json

  before_action :set_organisation, only: [:new, :create]
  before_action :set_user, only: [:edit, :update, :destroy]

  def index
    @users = policy_scope(User).order(Arel.sql('LOWER(last_name)')).page(params[:page])
    filter_users if params[:user] && params[:user][:search]
  end

  def new
    @user = User.new
    @user.organisation_id = current_pro.organisation_id
    @organisation = current_pro.organisation
    authorize(@user)
    respond_right_bar_with @user
  end

  def create
    @user = User.new(user_params)
    @user.organisation_id = current_pro.organisation_id
    @organisation = current_pro.organisation
    authorize(@user)
    flash[:notice] = "L'usager a été créé." if @user.save
    respond_right_bar_with @user, location: organisation_users_path(@organisation)
  end

  def edit
    authorize(@user)
    respond_right_bar_with @user
  end

  def update
    authorize(@user)
    flash[:notice] = "L'usager a été modifié." if @user.update(user_params)
    respond_right_bar_with @user, location: organisation_users_path(@user)
  end

  def destroy
    authorize(@user)
    @user.destroy
    redirect_to organisation_users_path(@user.organisation), notice: "L'usager a été supprimé."
  end

  private

  def filter_users
    @users = @users.search_by_name(params[:user][:search])
    respond_to do |format|
      format.js { render partial: 'search-results' }
    end
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone_number, :birth_date, :address)
  end

  def set_user
    @user = policy_scope(User).find(params[:id])
  end
end