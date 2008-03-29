module MoviesHelper
  include TagsHelper
  
  def quality_options
    [
      ['Retail', 'retail'],
      ['Copy', 'copy'],
      ['Download', 'download']
    ]
  end
end
