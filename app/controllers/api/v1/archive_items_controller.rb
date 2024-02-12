class Api::V1::ArchiveItemsController < ApplicationController
  include ActiveStorage::SetCurrent
  include Rails.application.routes.url_helpers
  def index
    archive_items = ArchiveItem.all.where(draft: false)
    archive_items = filter_tags(archive_items)
    archive_items = filter_medium_and_year(archive_items).order(created_at: :desc)
    render json: archive_items
  end

  def pages_index
    archive_items = ArchiveItem.where(draft: false).tagged_with(params[:page_tags], :any => true)
    archive_items = filter_tags(archive_items)
    archive_items = filter_medium_and_year(archive_items).order(created_at: :desc)

    render json: archive_items
  end

  def timeline
    # page_tags filters results by what's connected to a given page
    if params[:page_tags].present?
      timeline_items = ArchiveItem.where(draft: false).tagged_with(params[:page_tags], :any => true).where.not(:year => nil).order(year: :asc)
    else
      timeline_items = ArchiveItem.where(draft: false).where.not(:year => nil).order(year: :asc)
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
    # get items with matching tags
    if params[:page_tags] && params[:page_tags].join.empty?
      tag_archive_items = ArchiveItem.where(draft: false).tagged_with(params[:page_tags], :on => :tags, :any => true).search_archive_items(params[:q])
    end

    # get items with matching collections
    if params[:page_collections] && params[:page_collections].join.empty?
      collection_archive_items = ArchiveItem.where(draft: false).tagged_with(params[:page_collections], :on => :collections, :any => true).search_archive_items(params[:q])
    end

    if tag_archive_items && collection_archive_items
      # if both item and collection items exist, combine them
      archive_items = tag_archive_items.or(collection_archive_items)
    elsif tag_archive_items
      # if only one exists, use that
      archive_items = filter_tags(tag_archive_items)
    elsif collection_archive_items
      archive_items = filter_tags(collection_archive_items)
    else
      # if none of the above conditions are met, just search for items
      archive_items = ArchiveItem.where(draft: false).search_archive_items(params[:q])
      archive_items = filter_tags(archive_items)
    end

    archive_items = filter_medium_and_year(archive_items)

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
      path = rails_blob_url(item.poster_image) 
    elsif item.medium_photos.attached?
      path = rails_blob_url(item.medium_photos[0])
    elsif item.content_files.attached?
      path = rails_blob_url(item.content_files[0])
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
    @archive_item ||= ArchiveItem.where(draft: false).find(params[:id])
  end
end