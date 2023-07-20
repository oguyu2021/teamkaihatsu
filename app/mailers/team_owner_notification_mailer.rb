class TeamOwnerNotificationMailer < ApplicationMailer
  def notify_new_owner(team, new_owner)
    @team = team
    @new_owner = new_owner
    mail(to: new_owner.email, subject: "You are now the owner of #{team.name}")
  end
end
