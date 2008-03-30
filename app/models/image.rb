class Image < ActiveRecord::Base
  require RAILS_ROOT+"/vendor/rails/actionpack/lib/action_controller/integration.rb" 
  
  has_attachment :storage => :file_system,
                 :content_type => :image,
                 :path_prefix => 'public/assets',
                 :thumbnails => { :thumb => '75x75>'},
                 :max_size => 2.megabytes
                 
  belongs_to :movie
  
  attr_reader :downloaded_file_path
  
  def after_save
    File.delete(@downloaded_file_path) if @downloaded_file_path
  end
  
  def download_from_url(url)
    @downloaded_file_path = "#{RAILS_ROOT}/tmp/dl-#{rand(1000000)}.jpg"
    downloaded_data = File.new(@downloaded_file_path,"w")
    downloaded_data.puts open(url).read 
    downloaded_data.close
    self.uploaded_data = ActionController::TestUploadedFile.new(@downloaded_file_path,'image/jpeg')
  end
    
end
