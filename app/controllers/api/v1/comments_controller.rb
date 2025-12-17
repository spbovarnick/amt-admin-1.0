class Api::V1::CommentsController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
        ArchiveCommentMailer.comment_email(params[:title], params[:id], params[:uid], params[:first_name], params[:last_name], params[:email_addy], params[:subject], params[:comment]).deliver_later
        render json: { status: 'success', message: "Email sent!"}
    rescue => e
        Rails.logger.error(e)
        render json: { status: "error", error: e.message }, status: 500
    end
end