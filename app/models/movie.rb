class Movie < ActiveRecord::Base
  acts_as_taggable
  
  has_one :image
  
  validates_uniqueness_of :title
  
  attr_accessor :genres
  
  # def after_save
  #   self.tag_list = @my_tagnames
  # end
  # 
  # def genres=(tag_list)
  #   @my_tagnames = tag_list
  # end
  
  def release=(val)
    write_attribute(:release, Date.parse(val))
  end

end
