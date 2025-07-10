class WeeklyCsvMailer < ApplicationMailer
  def csv_ready
    @users = params[:users]
    @url = params[:url]
    puts "From Mailer: #{@url}"
    mail(to: @users, subject: "Your Weekly CSV for #{Date.today} is Ready")
  end
end