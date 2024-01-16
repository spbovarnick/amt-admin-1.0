class ArchiveTagsController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!, only: [:new, :edit, :update, :destroy, :index]
  before_action :set_archive_tag, only: %i[ show edit update destroy ]
  before_action :authorize_archivist

  # GET /archive_tags or /archive_tags.json
  def index
    page_items = params[:page_items].present? ? params[:page_items] : 25

    if params[:archive_q]
      @pagy, @archive_tags = pagy(ArchiveTag.ransack(name_cont: params[:archive_q]).result, page: params[:page], items: page_items)
    else
      @pagy, @archive_tags = pagy(ArchiveTag.all.order(name: :asc), page: params[:page], items: page_items)
    end
  end

  # GET /archive_tags/1 or /archive_tags/1.json
  def show
  end

  # GET /archive_tags/new
  def new
    @archive_tag = ArchiveTag.new
    @current_user = current_user
  end

  # GET /archive_tags/1/edit
  def edit
    @current_user = current_user
  end

  # POST /archive_tags or /archive_tags.json
  def create
    @archive_tag = ArchiveTag.new(archive_tag_params)

    respond_to do |format|
      if @archive_tag.save
        format.html { redirect_to archive_tags_path, notice: "Archive tag was successfully created." }
        format.json { render archive_tags_path }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @archive_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /archive_tags/1 or /archive_tags/1.json
  def update
    old_name = @archive_tag.name
    
    respond_to do |format|
      if @archive_tag.update(archive_tag_params)
        ArchiveItem.tagged_with(old_name, :on => :tags).each do |item|
          item.tag_list.remove(old_name)
          item.tag_list.add(@archive_tag.name)
          item.update_columns(search_tags: item.tag_list.join(', '))
          item.save
        end
        format.html { redirect_to archive_tags_path, notice: "Archive tag was successfully updated." }
        format.json { render :show, status: :ok, location: @archive_tag }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @archive_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /archive_tags/1 or /archive_tags/1.json
  def destroy
    @archive_tag.destroy
    respond_to do |format|
      format.html { redirect_to archive_tags_url, notice: "Archive tag was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_archive_tag
      @archive_tag = ArchiveTag.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def archive_tag_params
      params.require(:archive_tag).permit(:name, :created_by, :updated_by)
    end
end
