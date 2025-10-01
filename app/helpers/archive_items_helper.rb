module ArchiveItemsHelper
  def sort_link(label, base, default_dir: :asc)
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

    link_to label,
      archive_items_path(request.query_parameters.merge(sort: next_key, page: nil)),
      class: css
  end
end
