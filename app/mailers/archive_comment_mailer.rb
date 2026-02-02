class ArchiveCommentMailer < ApplicationMailer
  default from: -> { Rails.application.credentials[Rails.env.to_sym][:gmail] }

    def comment_email(item_comment, title, id, uid, first_name, last_name, email_addy, subject, comment)
        @item_comment = item_comment
        @first_name = first_name
        @last_name = last_name
        @email_addy = email_addy
        @subject = subject
        @comment = comment
        if item_comment
            @title = title
            @id = id
            @uid = uid
            @subject = subject + " " + uid
        end
        mail(to: Rails.application.credentials[Rails.env.to_sym][:gmail],
            subject: @subject,
        )
    end
end
