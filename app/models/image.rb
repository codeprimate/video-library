class Image < ActiveRecord::Base
  has_attachment :storage => :file_system,
                 :content_type => :image
                 :thumbnails => { :thumb => [50, 50]},
                 :max_size => 2.megabytes
                 
  belongs_to :movie
end
