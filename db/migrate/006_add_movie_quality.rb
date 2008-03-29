class AddMovieQuality < ActiveRecord::Migration
  def self.up
    add_column :movies, :quality, :string
  end

  def self.down
    remove_column :movies, :quality
  end
end
