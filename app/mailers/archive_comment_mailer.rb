class ArchiveCommentMailer < ApplicationMailer
  default from: -> { Rails.application.credentials[Rails.env.to_sym][:gmail] }

    def comment_email(title, id, uid, first_name, last_name, email_addy, subject, comment)
        @title = title
        @id = id
        @uid = uid
        @first_name = first_name
        @last_name = last_name
        @email_addy = email_addy
        @subject = subject
        @comment = comment
        mail(to: Rails.application.credentials[Rails.env.to_sym][:gmail],
            subject: subject + " " + @uid,
        )
    end
end
