class NewsItemsController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!, only: [:new, :edit, :update, :destroy, :index]
  before_action :set_news_item, only: %i[ show edit update destroy ]
  before_action :authorize_board_member
  PAGE_ITEMS = 25

  # GET /news_items or /news_items.json
  def index
    if params[:archive_q]
      @pagy, @news_items = pagy(NewsItem.ransack(headline_cont: params[:archive_q]).result, page: params[:page], items: PAGE_ITEMS )
    else
      @pagy, @news_items = pagy(NewsItem.all.order(created_at: :desc), page: params[:page], items: PAGE_ITEMS)
    end
  end

  # GET /news_items/1 or /news_items/1.json
  def show
  end

  # GET /news_items/new
  def new
    @news_item = NewsItem.new
    @current_user = current_user
  end

  # GET /news_items/1/edit
  def edit
    @current_user = current_user
  end

  # POST /news_items or /news_items.json
  def create
    @news_item = NewsItem.new(news_item_params)

    respond_to do |format|
      if @news_item.save
        format.html { redirect_to news_items_path, notice: "News item was successfully created." }
        format.json { render :show, status: :created, location: @news_item }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @news_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /news_items/1 or /news_items/1.json
  def update
    @news_item = NewsItem.find(params[:id])

    if params[:clear_photo] === "true"
      @news_item.photo.purge
    end

    respond_to do |format|
      if @news_item.update(news_item_params)
        format.html { redirect_to news_items_path, notice: "News item was successfully updated." }
        format.json { render :show, status: :ok, location: @news_item }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @news_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /news_items/1 or /news_items/1.json
  def destroy
    @news_item.destroy
    respond_to do |format|
      format.html { redirect_to news_items_url, notice: "News item was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_news_item
      @news_item = NewsItem.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def news_item_params
      params.require(:news_item).permit(:headline, :author, :body, :created_by, :updated_by, :photo, :cta_text, :cta_link)
    end
end
