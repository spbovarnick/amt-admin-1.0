class Api::V1::CommentsController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
        ArchiveCommentMailer.comment_email(params[:text], params[:title], params[:id]).deliver_now
        render json: { status: 'success', message: "Email sent!"}
    rescue => e
        render json: {error: e.message}
    end
end