class ModMovieRelease < ActiveRecord::Migration
  def self.up
    change_column :movies, :release, :date
  end

  def self.down
    change_column :movies, :release, :string
  end
end
