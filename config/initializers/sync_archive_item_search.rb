Rails.application.config.after_initialize do
  ActionText::RichText.after_commit on: [:create, :update] do
    if record_type == "ArchiveItem" && name == "medium_notes"
      record.update_column(:search_medium_notes, body&.to_plain_text)
    end
  end
end