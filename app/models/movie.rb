class Movie < ActiveRecord::Base
  acts_as_taggable
  
  has_one :image
  
  validates_uniqueness_of :title
  
  attr_accessor :genres
  
  def before_save
    i = Image.new
    i.download_from_url(self.image_url)
    self.image = i
    
    if self.title.match(/^the /i)
      self.title.sub!(/^the /i,'')
    end
  end
  
  def release=(val)
    write_attribute(:release, Date.parse(val))
  end

end
