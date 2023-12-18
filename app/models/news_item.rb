class NewsItem < ApplicationRecord
    has_rich_text :body
    has_one_attached :photo
end

