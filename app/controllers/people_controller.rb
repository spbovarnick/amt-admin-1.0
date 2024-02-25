class PeopleController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!, only: [:new, :edit, :update, :destroy, :index]
  before_action :set_person, only: %i[ show edit update destroy ]

  # GET /people or /people.json
  def index
    page_items = params[:page_items].present? ? params[:page_items] : 25

    if params[:archive_q]
      @pagy, @people = pagy(Person.ransack(name_cont: params[:archive_q]).result, page: params[:page], items: page_items)
    else
      @pagy, @people = pagy(Person.all.order(name: :asc), page: params[:page], items: page_items)
    end
  end

  # GET /people/1 or /people/1.json
  def show
  end

  # GET /people/new
  def new
    @person = Person.new
    @submit_text = "Add Person"
    @current_user = current_user
  end

  # GET /people/1/edit
  def edit
    @submit_text = "Update Person"
    @current_user = current_user
  end

  # POST /people or /people.json
  def create
    @person = Person.new(person_params)

    respond_to do |format|
      if @person.save
        format.html { redirect_to people_path, notice: "Person was successfully created." }
        format.json { render :show, status: :created, location: @person }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /people/1 or /people/1.json
  def update
    old_name = @person.name

    respond_to do |format|
      if @person.update(person_params)
        # this iterator updates search strings of all archive item instances tagged with this @person, necessary bc acts_as_ordered_taggable_on abstracts archive item instances from person instances
        ArchiveItem.tagged_with(old_name, :on => :people).each do |item|
          item.person_list.remove(old_name)
          item.person_list.add(@person.name)
          item.update_columns(search_people: item.person_list.join(', '))
          item.save
        end
        format.html { redirect_to people_path, notice: "Person was successfully updated." }
        format.json { render :show, status: :ok, location: @person }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1 or /people/1.json
  def destroy
    @person.destroy
    respond_to do |format|
      format.html { redirect_to people_url, notice: "Person was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_person
      @person = Person.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def person_params
      params.require(:person).permit(:name, :created_by, :updated_by)
    end
end
