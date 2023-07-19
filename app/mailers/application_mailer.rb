class ApplicationMailer < ActionMailer::Base
  def agenda_mail(agenda)
    @agenda = agenda 

    mail( to: @agenda.title, subject: "アジェンダ削除の確認メール")
  end
end
