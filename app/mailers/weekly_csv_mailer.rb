class WeeklyCsvMailer > ApplicationMailer
  def csv_ready
    @users = params[:user]
    @url = params[:url]
    puts "From Mailer: #{@url}"
    mail(to: user.email, subject: "Your Weekly Archive Items CSV for #{Date.today} is Ready")
  end
end