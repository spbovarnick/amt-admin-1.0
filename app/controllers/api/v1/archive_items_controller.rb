class Api::V1::ArchiveItemsController < ApplicationController
  include ActiveStorage::SetCurrent
  include Rails.application.routes.url_helpers
  def index
    archive_items = base_scope
    archive_items = filter_tags(archive_items)
    archive_items = filter_medium_and_year(archive_items).order(updated_at: :desc)
    render json: archive_items
  end

  def page_count
    archive_items = base_scope

    if params[:page_tags].present?
      archive_items = archive_items.tagged_with(params[:page_tags], :any => true)
    end

    archive_items = filter_tags(archive_items)
    archive_items = filter_medium_and_year_for_page_count(archive_items)
    render json: archive_items.count
  end

  def pages_index
    archive_items = base_scope.tagged_with(params[:page_tags], :any => true)
    archive_items = filter_tags(archive_items)
    archive_items = filter_medium_and_year(archive_items).order(updated_at: :desc)

    render json: archive_items
  end

  def timeline
    cache_key = "timeline/#{params[:page_tags]}"

    timeline_items = ArchiveItem
                    .select(:id, :year, :title, :date_is_approx, :medium)
                    .where(draft: false)
                    .tagged_with(params[:page_tags], :any => true)
                    .merge(ArchiveItem.where.not(year: nil))
                    .with_attached_poster_image
                    .with_attached_medium_photos
                    .with_attached_content_files
                    .order(year: :asc)

     items_as_json = Rails.cache.fetch(cache_key, expires_in: 4.hours ) do
      timeline_items.map do |item|
        {
          id: item.id,
          year: item.year,
          title: item.title,
          date_is_approx: item.date_is_approx,
          medium: item.medium,
          poster_image_url: item.poster_image.attached? ? item.poster_image.url() : nil,
          medium_photo_url: item.medium_photos.attached? ? item.medium_photos[0].url() : nil,
          content_file_url: item.content_files.attached? ? item.content_files[0].url() : nil,
          time: Time.current
        }
      end
    end

    render json: items_as_json
  end

  def search
    archive_items = search_scope
    archive_items = filter_medium_and_year(archive_items)

    render json: archive_items
  end

  def search_page_count
    archive_items = search_scope
    archive_items = filter_medium_and_year(archive_items)

    render json: archive_items.count
  end

  def show
    if archive_item
      render json: archive_item
    else
      render json: archive_item.errors
    end
  end

  private

  def base_scope
    ArchiveItem.where(draft: false)
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
    archive_items
  end

  def filter_medium_and_year_for_page_count(archive_items)
    if params[:year].present? && params[:medium].present?
      archive_items = archive_items.where({year: params[:year].to_i..(params[:year].to_i + 9), medium: params[:medium]})
    elsif params[:year].present?
      archive_items = archive_items.where({year: params[:year].to_i..(params[:year].to_i + 9)})
    elsif params[:medium].present?
      archive_items = archive_items.where({medium: params[:medium]})
    end
    archive_items
  end

  def search_scope
# get items with matching tags
    if params[:page_tags] && params[:page_tags].join.empty?
      tag_archive_items = base_scope.tagged_with(params[:page_tags], :on => :tags, :any => true).search_archive_items(params[:q])
    end

    # get items with matching collections
    if params[:page_collections] && params[:page_collections].join.empty?
      collection_archive_items = base_scope.tagged_with(params[:page_collections], :on => :collections, :any => true).search_archive_items(params[:q])
    end

    archive_items =
      if tag_archive_items && collection_archive_items
        # if both item and collection items exist, combine them
        tag_archive_items.or(collection_archive_items)
      elsif tag_archive_items
        # if only one exists, use that
        filter_tags(tag_archive_items)
      elsif collection_archive_items
        filter_tags(collection_archive_items)
      else
        # if none of the above conditions are met, just search for items
        base_scope.search_archive_items(params[:q])
      end

      filter_tags(archive_items)
  end

  def archive_item
    @archive_item ||= ArchiveItem.where(draft: false).find(params[:id])
  end
end