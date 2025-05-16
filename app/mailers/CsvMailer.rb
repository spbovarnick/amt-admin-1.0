class CsvMailer < ApplicationMailer
  def csv_ready
    @user = params[:user]
    @url = params[:url]
    mail(to: @user.email, subject: "Your Archive Items CSV is Ready")
  end
end