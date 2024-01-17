class LeadershipRolesController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!, only: [:new, :edit, :update, :destroy, :index]
  before_action :set_leadership_role, only: %i[ show edit update destroy ]
  before_action :authorize_board_member

  # GET /leadership_roles or /leadership_roles.json
  def index
    @leadership_roles = LeadershipRole.all.order(position: :asc)
    @board_roles = LeadershipRole.where(:section => "board").order(position: :asc)
    @staff_roles = LeadershipRole.where(:section => "staff").order(position: :asc)
  end

  # GET /leadership_roles/1 or /leadership_roles/1.json
  def show
  end

  # GET /leadership_roles/new
  def new
    @leadership_role = LeadershipRole.new
  end

  # GET /leadership_roles/1/edit
  def edit
    board_items_count = LeadershipRole.where(:section => "board").size
    staff_items_count = LeadershipRole.where(:section => "staff").size

    @position_options = []

    if @leadership_role.section === "board"
      board_items_count.times do |idx|
        @position_options.push(["#{idx + 1}", idx + 1])
      end
    else
      staff_items_count.times do |idx|
        @position_options.push(["#{idx + 1}", idx + 1])
      end
    end
  end

  # POST /leadership_roles or /leadership_roles.json
  def create
    @leadership_role = LeadershipRole.new(leadership_role_params)
    board_items_count = LeadershipRole.where(:section => "board").size
    staff_items_count = LeadershipRole.where(:section => "staff").size

    position_options = []

    if @leadership_role.section === "board"
      @leadership_role.position = board_items_count + 1;
    else
      @leadership_role.position = staff_items_count + 1;
    end

    respond_to do |format|
      if @leadership_role.save
        format.html { redirect_to leadership_roles_path, notice: "Leadership role was successfully created." }
        format.json { render :show, status: :created, location: @leadership_role }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @leadership_role.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /leadership_roles/1 or /leadership_roles/1.json
  def update
    respond_to do |format|
      # Logic for managing unique positions
      if leadership_role_params[:position] && @leadership_role.position
        new_pos = Integer(leadership_role_params[:position])
        old_pos = Integer(@leadership_role.position)
        current_section = leadership_role_params[:section] || @leadership_role.section

        if new_pos > old_pos
          in_between = LeadershipRole.where("position <= ? AND position > ? AND section = ?", new_pos, old_pos, current_section)
          in_between.each do |item|
            LeadershipRole.update(item.id, :position => item.position - 1)
          end
        elsif new_pos < old_pos
          in_between = LeadershipRole.where("position < ? AND position >= ? AND section = ?", old_pos, new_pos, current_section)
          in_between.each do |item|
            LeadershipRole.update(item.id, :position => item.position + 1)
          end
        end
      end

      if @leadership_role.update(leadership_role_params)
        format.html { redirect_to leadership_roles_path, notice: "Leadership role was successfully updated." }
        format.json { render :show, status: :ok, location: @leadership_role }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @leadership_role.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /leadership_roles/1 or /leadership_roles/1.json
  def destroy
    current_section = @leadership_role.section
    @leadership_role.destroy
    respond_to do |format|
      old_pos = Integer(@leadership_role.position)
      higher_items = LeadershipRole.where("position > ? AND section = ?", old_pos, current_section)
      higher_items.each do |item|
        LeadershipRole.update(item.id, :position => item.position - 1)
      end

      format.html { redirect_to leadership_roles_url, notice: "Leadership role was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_leadership_role
      @leadership_role = LeadershipRole.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def leadership_role_params
      params.require(:leadership_role).permit(:name, :title, :headshot, :section, :position)
    end
end
