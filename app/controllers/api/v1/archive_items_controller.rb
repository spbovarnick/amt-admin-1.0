class Api::V1::ArchiveItemsController < ApplicationController
  include ActiveStorage::SetCurrent
  include Rails.application.routes.url_helpers
  def index
    archive_items = ArchiveItem.all
    archive_items = filter_tags(archive_items)
    archive_items = filter_medium_and_year(archive_items).order(created_at: :desc)
    render json: archive_items
  end

  def pages_index
    archive_items = ArchiveItem.tagged_with(params[:page_tags], :any => true)
    archive_items = filter_tags(archive_items)
    archive_items = filter_medium_and_year(archive_items).order(created_at: :desc)

    render json: archive_items
  end

  def timeline
    # page_tags filters results by what's connected to a given page
    if params[:page_tags].present?
      timeline_items = ArchiveItem.tagged_with(params[:page_tags], :any => true).where.not(:year => nil).order(year: :asc)
    else
      timeline_items = ArchiveItem.where.not(:year => nil).order(year: :asc)
    end

    cleaned_timeline_items = []
    timeline_items.each do |item|
      clean_item = {
        id: item.id,
        year: item.year,
        title: item.title.split("").length > 37 ? item.title.split("").slice(0, 37).push("...").join() : item.title,
        media: choose_timeline_media(item),
        date_is_approx: item.date_is_approx
      }
      cleaned_timeline_items.push(clean_item)
    end

    render json: cleaned_timeline_items 
  end
  
  def search
    if params[:page_tags].present?
      archive_items = ArchiveItem.tagged_with(params[:page_tags], :any => true).search_archive_items(params[:q])
      archive_items = filter_tags(archive_items)
      archive_items = filter_medium_and_year(archive_items)
    else
      archive_items = ArchiveItem.search_archive_items(params[:q])
      archive_items = filter_tags(archive_items)
      archive_items = filter_medium_and_year(archive_items)
    end

    render json: archive_items
  end

  def show
    if archive_item
      render json: archive_item
    else
      render json: archive_item.errors
    end
  end

  private

  def choose_timeline_media(item)
    valid_formats = [".jpg", ".jpeg", ".png"]
    if item.poster_image.attached?
      path = rails_blob_path(item.poster_image, only_path:true)
    elsif item.medium_photos.attached?
      path = rails_blob_path(item.medium_photos[0], only_path:true)
    elsif item.content_files.attached?
      path = rails_blob_path(item.content_files[0], only_path:true)
      if !valid_formats.include?(File.extname(path))
        path = nil
      end
    end
    
    {
      url: path,
      medium: item.medium
    }
    
  end

  def filter_tags(archive_items)
    allTags = params.slice(:tags, :locations, :comm_groups, :people, :collections).values.flatten.compact
    allTags.length > 0 ? archive_items.tagged_with(allTags, :any => true) : archive_items
  end

  def filter_medium_and_year(archive_items)
    if params[:year].present? && params[:medium].present?
      archive_items = archive_items.where({year: params[:year].to_i..(params[:year].to_i + 9), medium: params[:medium]}).offset(params[:offset]).limit(params[:limit])
    elsif params[:year].present?
      archive_items = archive_items.where({year: params[:year].to_i..(params[:year].to_i + 9)}).offset(params[:offset]).limit(params[:limit])
    elsif params[:medium].present?
      archive_items = archive_items.where({medium: params[:medium]}).offset(params[:offset]).limit(params[:limit])
    else
      archive_items = archive_items.offset(params[:offset]).limit(params[:limit])
    end
  end

  def archive_item
    @archive_item ||= ArchiveItem.find(params[:id])
  end
end