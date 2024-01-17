class CommGroupsController < ApplicationController
  before_action :set_comm_group, only: %i[ show edit update destroy ]
  layout 'admin'
  before_action :authenticate_user!, only: [:new, :edit, :update, :destroy, :index]
  before_action :set_comm_group, only: %i[ show edit update destroy ]
  before_action :authorize_archivist

  # GET /comm_groups or /comm_groups.json
  def index
    page_items = params[:page_items].present? ? params[:page_items] : 25

    if params[:archive_q]
      @pagy, @comm_groups = pagy(CommGroup.ransack(name_cont: params[:archive_q]).result, page: params[:page], items: page_items)
    else
      @pagy, @comm_groups = pagy(CommGroup.all.order(name: :asc), page: params[:page], items: page_items)
    end
  end

  # GET /comm_groups/1 or /comm_groups/1.json
  def show
  end

  # GET /comm_groups/new
  def new
    @comm_group = CommGroup.new
    @submit_text = "Add Group"
    @current_user = current_user
  end

  # GET /comm_groups/1/edit
  def edit
    @submit_text = "Update Group"
    @current_user = current_user
  end

  # POST /comm_groups or /comm_groups.json
  def create
    @comm_group = CommGroup.new(comm_group_params)

    respond_to do |format|
      if @comm_group.save
        format.html { redirect_to comm_groups_path, notice: "Group was successfully created." }
        format.json { render :show, status: :created, location: @comm_group }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @comm_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comm_groups/1 or /comm_groups/1.json
  def update
    old_name = @comm_group.name

    respond_to do |format|
      if @comm_group.update(comm_group_params)
      # this iterator updates search strings of all archive item instances tagged with this @comm_group, necessary bc acts_as_ordered_taggable_on abstracts archive item instances from comm_group instances
        ArchiveItem.tagged_with(old_name, :on => :comm_groups).each do |item|
          item.comm_group_list.remove(old_name)
          item.comm_group_list.add(@comm_group.name)
          item.update_columns(search_comm_groups: item.comm_group_list.join(', '))
          item.save
        end
        format.html { redirect_to comm_groups_path, notice: "Group was successfully updated." }
        format.json { render :show, status: :ok, location: @comm_group }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @comm_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comm_groups/1 or /comm_groups/1.json
  def destroy
    @comm_group.destroy
    respond_to do |format|
      format.html { redirect_to comm_groups_url, notice: "Comm group was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comm_group
      @comm_group = CommGroup.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def comm_group_params
      params.require(:comm_group).permit(:name, :created_by, :updated_by)
    end
end
