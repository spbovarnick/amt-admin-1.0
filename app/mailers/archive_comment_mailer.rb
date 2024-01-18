class ArchiveCommentMailer < ApplicationMailer
  default from: -> { Rails.application.credentials[Rails.env.to_sym][:gmail] }

    def comment_email(comment, title, id)
        @comment = comment
        @title = title
        @id = id
        mail(to: Rails.application.credentials[Rails.env.to_sym][:gmail], 
            subject: 'Archive Item Comment - ' + @title,
        )
    end
end
