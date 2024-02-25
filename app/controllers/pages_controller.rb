class PagesController < ApplicationController
  layout 'admin', except: [:display]
  before_action :authenticate_user!, only: [:new, :edit, :update, :destroy, :index]
  before_action :set_page, only: %i[ show edit update destroy ]

  # GET /pages or /pages.json
  def index
    if current_user.page == "global"
      @pages = Page.all
    else
      @pages = Page.where( :tag => current_user.page)
    end
    @root_url = root_url
  end

  # GET /pages/1 or /pages/1.json
  def show
  end

  # GET /pages/new
  def new
    @tag_options = ArchiveTag.all.order(name: :desc).pluck(:name)
    @comm_group_options = CommGroup.all.order(name: :desc).pluck(:name)
    @collection_options = Collection.all.order(name: :desc).pluck(:name)
    @page = Page.new
  end

  # GET /pages/1/edit
  def edit
    @tag_options = ArchiveTag.all.order(name: :desc).pluck(:name)
    @comm_group_options = CommGroup.all.order(name: :desc).pluck(:name)
    @collection_options = Collection.all.order(name: :desc).pluck(:name)
    @page = Page.find(params[:id])
  end

  # POST /pages or /pages.json
  def create
    @page = Page.new(page_params)

    respond_to do |format|
      if @page.save
        @page.update_attribute(:slug, @page.title.to_s.parameterize)
        format.html { redirect_to pages_path, notice: "Page was successfully created." }
        format.json { render :show, status: :created, location: @page }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pages/1 or /pages/1.json
  def update
    respond_to do |format|
      if @page.update(page_params)
        @page.update_attribute(:slug, @page.title.to_s.parameterize)
        format.html { redirect_to pages_path, notice: "Page was successfully updated." }
        format.json { render :show, status: :ok, location: @page }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1 or /pages/1.json
  def destroy
    @page.destroy
    respond_to do |format|
      format.html { redirect_to pages_url, notice: "Page was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_page
      @page = Page.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def page_params
      params.require(:page).permit(:title, :description, :tag, :slug, :header_file, :tag_list, :comm_groups, :ctatext, :ctalink, :subtitle, :donate_url, :collection, :draft, :mail_list_url)
    end
end
