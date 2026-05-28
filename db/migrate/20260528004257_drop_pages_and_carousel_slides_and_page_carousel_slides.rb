class DropPagesAndCarouselSlidesAndPageCarouselSlides < ActiveRecord::Migration[7.1]
  def up
    drop_table :pages
    drop_table :page_carousel_slides
    drop_table :carousel_slides
  end

  def down
    create_table :carousel_slides do |t|
      t.string  :title
      t.text    :description
      t.string  :link
      t.integer :position
      t.timestamps
    end

    create_table :pages do |t|
      t.string  :title
      t.text    :description
      t.string  :tag
      t.string  :slug
      t.string  :comm_groups
      t.string  :ctatext
      t.string  :ctalink
      t.text    :subtitle
      t.string  :donate_url
      t.string  :collection
      t.boolean :draft, default: false
      t.string  :mail_list_url
      t.timestamps
    end

    create_table :page_carousel_slides do |t|
      t.string  :title
      t.text    :description
      t.string  :collections
      t.string  :page
      t.integer :position
      t.integer :year
      t.string  :comm_groups
      t.string  :medium
      t.string  :people
      t.string  :locations
      t.string  :tags
      t.timestamps
    end
  end
end
