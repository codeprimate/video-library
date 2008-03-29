class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.integer :size, :width, :height, :parent_id, :movie_id
      t.string :content_type, :filename, :thumbnail
      t.timestamps
    end
    add_index :images, :parent_id
    add_index :images, :movie_id
  end

  def self.down
    drop_table :images
  end
end
