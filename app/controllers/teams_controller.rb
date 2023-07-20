class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: %i[show edit update destroy assign_owner ]

  def index
    @teams = Team.all
  end

  def assign_owner
    new_owner = User.find(params[:owner_id])
    if current_user == @team.owner && new_owner != @team.owner
      @team.update(owner: new_owner)
      TeamOwnerNotificationMailer.notify_new_owner(@team, new_owner).deliver_now
      redirect_to team_path(@team.id), notice: '権限を移動しました！'
    else
      redirect_to team_path(@team.id), alert: '権限移動に失敗しました。'
    end
  end

  def show
    @working_team = @team
    change_keep_team(current_user, @team)
  end

  def new
    @team = Team.new
  end

  def edit
    unless @team.owner == current_user
    redirect_to team_path(@team.id), notice: I18n.t('views.messages.leader_only_edit')
    end
  end

  def create
    @team = Team.new(team_params)
    @team.owner = current_user
    if @team.save
      @team.invite_member(@team.owner)
      redirect_to team_path(@team.id), notice: I18n.t('views.messages.create_team')
    else
      flash.now[:error] = I18n.t('views.messages.failed_to_save_team')
      render :new
    end
  end

  def update
    if @team.update(team_params)
      redirect_to team_path(@team.id), notice: I18n.t('views.messages.update_team')
    else
      flash.now[:error] = I18n.t('views.messages.failed_to_save_team')
      render :edit
    end
  end

  def destroy
    if current_user == @team.owner || current_user == @team.assigns.find_by(user_id: params[:user_id]).user
      @team.destroy
      redirect_to teams_url, notice: 'Team was successfully destroyed.'
    else
      redirect_to team_path(@team.id), alert: 'You do not have permission to delete this team.'
    end
  end

  def dashboard
    @team = current_user.keep_team_id ? Team.find(current_user.keep_team_id) : current_user.teams.first
  end

  private

  def set_team
    @team = Team.friendly.find(params[:id])
  end

  def team_params
    params.fetch(:team, {}).permit %i[name icon icon_cache owner_id keep_team_id]
  end
end
