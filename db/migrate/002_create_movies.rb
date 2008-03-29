class CreateMovies < ActiveRecord::Migration
  def self.up
    create_table :movies do |t|
      t.string :title, :director, :release,:summary, :image_url
      t.text :summary
      t.decimal :runtime
      t.decimal :rating, :precision => 2, :scale => 1
      t.timestamps
    end
  end

  def self.down
    drop_table :movies
  end
end
