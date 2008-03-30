class Movie < ActiveRecord::Base
  acts_as_taggable
  
  has_one :image
  
  validates_uniqueness_of :title
  
  attr_accessor :genres
  
  def before_save
    unless image_url.empty?
      unless self.image
        i = Image.new
      else
        i = self.image
      end
      i.download_from_url(self.image_url)
      self.image = i
    end 
    
    if self.title.match(/^the /i)
      self.title.sub!(/^the /i,'')
    end
  rescue
    logger.info "Error downloading image."
  end
  
  def release=(val)
    write_attribute(:release, Date.parse(val)) unless val.empty?
  end

end
