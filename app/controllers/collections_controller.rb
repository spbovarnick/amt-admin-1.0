class CollectionsController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!, only: [:new, :edit, :update, :destroy, :index]
  before_action :set_collection, only: %i[ show edit update destroy ]
  PAGE_ITEMS = 25

  def find_by_name
    @collection = Collection.find_by(name: params[:name])
    if @collection
      render json: {id: @collection.id}
    else
      render json: {error: "Collection not found"}, status: :not_found
    end
  end

  # GET /collections or /collections.json
  def index
    if params[:archive_q]
      @pagy, @collections = pagy(Collection.ransack(name_cont: params[:archive_q]).result, page: params[:page], items: PAGE_ITEMS)
    else
      @pagy, @collections = pagy(Collection.all.order(name: :asc), page: params[:page], items: PAGE_ITEMS)
    end
  end

  # GET /collections/1 or /collections/1.json
  def show
  end

  # GET /collections/new
  def new
    @collection = Collection.new
    @submit_text = "Add Collection"
    @current_user = current_user
  end

  # GET /collections/1/edit
  def edit
    @submit_text = "Update Collection"
    @current_user = current_user
  end

  # POST /collections or /collections.json
  def create
    @collection = Collection.new(collection_params)

    respond_to do |format|
      if @collection.save
        format.html { redirect_to collections_path, notice: "Collection was successfully created." }
        format.json { render :show, status: :created, location: @collection }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /collections/1 or /collections/1.json
  def update
    old_name = @collection.name

    respond_to do |format|
      if @collection.update(collection_params)
        # this iterator updates search strings of all archive item instances tagged with this @collection, necessary bc acts_as_ordered_taggable_on abstracts archive item instances from collection instances
        ArchiveItem.tagged_with(old_name, :on => :collections).each do |item|
          item.collection_list.remove(old_name)
          item.collection_list.add(@collection.name)
          item.update_columns(search_collections: item.collection_list.join(', '))
          item.save
        end
        format.html { redirect_to collections_path, notice: "Collection was successfully updated." }
        format.json { render :show, status: :ok, location: @collection }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collections/1 or /collections/1.json
  def destroy
    @collection.destroy
    respond_to do |format|
      format.html { redirect_to collections_url, notice: "Collection was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_collection
      @collection = Collection.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def collection_params
      params.require(:collection).permit(:name, :created_by, :updated_by)
    end
end
