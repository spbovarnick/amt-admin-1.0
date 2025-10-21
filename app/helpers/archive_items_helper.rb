module ArchiveItemsHelper
  def sort_link(label, base, items, default_dir: :asc)
    current = params[:sort].to_s
    asc_key = base
    desc_key = "#{base}-desc"

    next_key =
      if current == asc_key
        desc_key
      elsif current == desc_key
        asc_key
      else
        default_dir == :desc ? desc_key : asc_key
      end

    css =
      if current == asc_key
        'sorted-down'
      elsif current == desc_key
        'sorted-up'
      end

      base_url = request.query_parameters.except(:page)

    link_to label,
      archive_items_path(base_url.merge(:sort => next_key, :page_items => items, page: nil)),
      class: css
  end

  def flagged_link
    if params[:sort] =='flagged'
      link_to 'Show All Archive Items',
        archive_items_path,
        class: 'table-header-button'
    else
      link_to 'Show Only Archive Items Missing Files',
        archive_items_path(request.query_parameters.merge(sort: 'flagged', page: nil)),
        class: 'table-header-button'
    end
  end
end
