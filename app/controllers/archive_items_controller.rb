require 'csv'
require "prawn"

class ArchiveItemsController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!, only: [:new, :edit, :update, :destroy, :index, :get_items, :sync_search_strings]
  before_action :store_return_to_session, only: [:new, :edit]
  def create_uid_pdf
    @archive_item = ArchiveItem.find(params[:id])

    pdf = Prawn::Document.new

    pdf.text @archive_item.uid, align: :center, size: 24
    pdf.text "Title: #{@archive_item.title}"
    pdf.text "Year: #{@archive_item.year}"
    pdf.text "Medium: #{@archive_item.medium}"
    pdf.text "UID: #{@archive_item.uid}"

    # send_data pdf.render filename: "#{@archive_item.uid}.pdf", type: 'application/pdf'
    item = ArchiveItem.find(params[:id])
    send_data generate_pdf(item), filename: "#{@archive_item.uid}.pdf", type: 'application/pdf'
  end

  def index
    page_items = params[:page_items].present? ? params[:page_items] : 25

    if params[:sort] == 'subject'
      @pagy, @archive_items = get_items({title: :asc}, page_items)
    elsif params[:sort] == 'subject-desc'
      @pagy, @archive_items = get_items({title: :desc}, page_items)
    elsif params[:sort] == 'draft'
      @pagy, @archive_items = get_items({draft: :asc}, page_items)
    elsif params[:sort] == 'draft-desc'
      @pagy, @archive_items = get_items({draft: :desc}, page_items)
    elsif params[:sort] == 'collection'
      @pagy, @archive_items = get_items({draft: :asc}, page_items)
    elsif params[:sort] == 'collection-desc'
      @pagy, @archive_items = get_items({draft: :desc}, page_items)
    elsif params[:sort] == 'medium'
      @pagy, @archive_items = get_items({medium: :asc}, page_items)
    elsif params[:sort] == 'medium-desc'
      @pagy, @archive_items = get_items({medium: :desc}, page_items)
    elsif params[:sort] == 'year'
      @pagy, @archive_items = get_items({year: :asc}, page_items)
    elsif params[:sort] == 'year-desc'
      @pagy, @archive_items = get_items({year: :desc}, page_items)
    elsif params[:sort] == 'location'
      @pagy, @archive_items = get_items({search_locations: :asc}, page_items)
    elsif params[:sort] == 'location-desc'
      @pagy, @archive_items = get_items({search_locations: :desc}, page_items)
    elsif params[:sort] == 'edited'
      @pagy, @archive_items = get_items({updated_at: :asc}, page_items)
    elsif params[:sort] == 'edited-desc'
      @pagy, @archive_items = get_items({updated_at: :desc}, page_items)
    elsif params[:sort] == 'flagged'
      if current_user.page == "global"
        @pagy, @archive_items = pagy(ArchiveItem.left_outer_joins(:content_files_attachments).where(active_storage_attachments: {id: nil}), page: params[:page], items: page_items)
      else
        @pagy, @archive_items = pagy(ArchiveItem.left_joins(:content_files_attachments).where(active_storage_attachments: {id: nil}), page: params[:page], items: page_items)
      end
    elsif params[:sort] == 'file_type'
      @pagy, @archive_items = get_items({file_type: :asc}, page_items)
    elsif params[:sort] == 'file_type-desc'
      @pagy, @archive_items = get_items({file_type: :desc}, page_items)
    elsif params[:archive_q]
      if current_user.page == "global"
        @pagy, @archive_items = pagy(ArchiveItem.search_cms_archive_items(params[:archive_q]), page: params[:page], items: page_items)
      else
        @pagy, @archive_items = pagy(ArchiveItem.tagged_with(current_user.page).search_cms_archive_items(params[:archive_q]), page: params[:page], items: page_items)
      end
    else
      @pagy, @archive_items = get_items({created_at: :desc}, page_items)
    end

    @total_item_count = @pagy.count

    @all_items = ArchiveItem.all

    respond_to do |format|
      format.html
      format.csv { send_data @all_items.to_csv, filename: "archive_items-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv"}
    end
  end

  def export_to_csv
    ExportArchiveItemsCsvJob.perform_later(current_user.id)
    redirect_to archive_items_path, notice: "Export started. You'll receive an email when it's ready."
  end

  def get_items(sort, num_items)
    if sort.keys.first == :file_type

      # subquery to get only first id of content_files array
      first_attachment_ids = ActiveStorage::Attachment
        .where(record_type: 'ArchiveItem', name: 'content_files')
        .group(:record_id)
        .select('MIN(id)')

      # make sort SQL friendly
      order_direction = sort.values.first == :asc ? 'ASC' : 'DESC'

      base_query = ArchiveItem
        .left_joins(content_files_attachments: :blob)
        .where(active_storage_attachments: { id: first_attachment_ids }) # only consider first id content_files
        .or(ArchiveItem.left_joins(content_files_attachments: :blob).where(active_storage_attachments: {id: nil})) # include items with no content_files
        .select("archive_items.*")
        .order("active_storage_blobs.content_type #{order_direction}")

    else
      base_query = current_user.page == "global" ? ArchiveItem.all.order(sort) : ArchiveItem.tagged_with(current_user.page).order(sort)
    end

    return pagy(base_query, page: params[:page], items: num_items)
  end

  def sync_search_strings
    @archive_items = ArchiveItem.all
    @archive_items.each do |item|
      # Sync all tag fields
      item.update_columns(search_locations: item.location_list.join(', '), search_tags: item.tag_list.join(', '), search_people: item.person_list.join(', '), search_comm_groups: item.comm_group_list.join(', '), search_collections: item.collection_list.join(', '))
    end
  end

  def copy
    @copied_item = ArchiveItem.find(params[:id])
    @archive_item = ArchiveItem.new
    @archive_item.copy_tags_from(@copied_item)
    @archive_item.year = @copied_item.year
    @archive_item.credit = @copied_item.credit
    @submit_text = "Create Item"
    @tag_options = ArchiveTag.all.order(name: :desc).pluck(:name)
    @location_options = Location.all.order(name: :desc).pluck(:name)
    @person_options = Person.all.order(name: :desc).pluck(:name)
    # @collection_options = Collection.all.order(name: :desc).pluck(:name, :id)
    @comm_group_options = CommGroup.all.order(name: :desc).pluck(:name)
    @current_user = current_user
  end

  def new
    @archive_item = ArchiveItem.new
    next_id = format('%06d', ArchiveItem.last.id + 1)
    @part1 = next_id[0, 3]
    @part2 = next_id[3, 3]
    @submit_text = "Create Item"
    @tag_options = ArchiveTag.all.order(name: :desc).pluck(:name)
    @location_options = Location.all.order(name: :desc).pluck(:name)
    @person_options = Person.all.order(name: :desc).pluck(:name)
    @collection_options = Collection.all.order(name: :desc).pluck(:name)
    @comm_group_options = CommGroup.all.order(name: :desc).pluck(:name)
    @current_user = current_user
  end

  def create
    @archive_item = ArchiveItem.create(archive_item_params)

    # Update search fields
    @archive_item.update_columns(search_locations: params[:archive_item][:location_list], search_tags: params[:archive_item][:tag_list], search_people: params[:archive_item][:person_list], search_comm_groups: params[:archive_item][:comm_group_list], search_collections: params[:archive_item][:collection_list].split("_").last)
    # ^ collection_list param is split here, because of concatenated value passed into #new view

    flash.alert = "An item has been created."
    redirect_to session.delete(:return_to) || archive_items_path
  end

  def show
    @archive_item = ArchiveItem.find(params[:id])
  end

  def edit
    if current_user.page == "global"
      @archive_item = ArchiveItem.find(params[:id])
    else
      begin
        @archive_item = ArchiveItem.tagged_with(current_user.page).find(params[:id])
      rescue
        redirect_to archive_items_path
      end
    end

    item_id = format('%06d', @archive_item.id)
    @part1 = item_id[0, 3]
    @part2 = item_id[3, 3]
    @archive_item.uid.present? ? @item_uid_str = @archive_item.uid.slice(8...) : nil
    @submit_text = "Update Item"
    @tag_options = ArchiveTag.all.order(name: :desc).pluck(:name)
    @location_options = Location.all.order(name: :desc).pluck(:name)
    @person_options = Person.all.order(name: :desc).pluck(:name)
    @collection_options = Collection.all.order(name: :desc).pluck(:name)
    @comm_group_options = CommGroup.all.order(name: :desc).pluck(:name)
    @current_user = current_user
  end

  def delete_medium_photo
    @archive_item = ArchiveItem.find(params[:id])
    photo = @archive_item.medium_photos.find(params[:medium_photo_id])
    photo.purge
    redirect_to edit_archive_item_path(@archive_item), notice: 'Photo was successfully deleted'
  end

  def update
    @archive_item = ArchiveItem.find(params[:id])

    # create new params hash to remove empty content_files and medium_photos
    update_params = archive_item_params

    # check if content_files is empty and remove it from update_params if it is
    if archive_item_params[:content_files] == [""]
      update_params.delete(:content_files)
    end

    # check if medium_photos is empty and remove it from update_params if it is
    if archive_item_params[:medium_photos] == [""]
      update_params.delete(:medium_photos)
    end

    # check if poster_image is empty and remove it from update_params if it is
    if archive_item_params[:poster_image] == [""]
      update_params.delete(:poster_image)
    end

    @archive_item.update(update_params)

    if params[:clear_poster_image] === "true"
      @archive_item.poster_image.purge
    end

    if params[:clear_medium_photo] === "true"
      @archive_item.medium_photo.purge
    end

    # Update search fields
    @archive_item.update_columns(search_locations: params[:archive_item][:location_list], search_tags: params[:archive_item][:tag_list], search_people: params[:archive_item][:person_list], search_comm_groups: params[:archive_item][:comm_group_list], search_collections: params[:archive_item][:collection_list].split("_").last)
    # ^ collection_list param is split here, because of concatenated value passed into #edit view)

    flash.alert = "An item has been updated."
    redirect_to session.delete(:return_to) || archive_items_path
  end

  def destroy
    @archive_item = ArchiveItem.find(params[:id])
    @archive_item.destroy

    redirect_to archive_items_path
  end

  private

  def generate_pdf(item)
    Prawn::Document.new do
      text item.uid, align: :center, size: 24
      text "Title: #{item.title}"
      text "Medium: #{item.medium}"
      text "UID: #{item.uid}"
    end.render
  end

  def store_return_to_session
    session[:return_to] = request.referrer if action_name.in?(['new', 'edit'])
  end

  def archive_item_params
    params.require(:archive_item).permit(:poster_image, :title, :medium, :year, :credit, :location, :tag_list, :location_list, :person_list, :comm_group_list, :collection_list, :date_is_approx, :content_notes, :medium_notes, :medium_photo, :search_tags, :search_locations, :search_people, :search_comm_groups, :search_collections, :created_by, :updated_by, :updated_at, :draft, content_files: [], :medium_photos => [])
  end
end
