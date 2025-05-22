class CsvMailer < ApplicationMailer
  def csv_ready
    @user = params[:user]
    @url = params[:url]
    puts "From Mailer: #{@url}"
    mail(to: @user.email, subject: "Your Archive Items CSV is Ready")
  end
end