module MovieMash
  require 'imdb'
  require 'tpb'
  
  class TopMovies
    
    def initialize
      @tpb_list = []
      @movies = []
      
      @tpb = Tpb::Search.new
      @imdb = Imdb::Search.new
    end
    
    private
    
    def get_list
      @tpb_list ||= @tpb.browse(100) 
    end
    
    def imdb_entry_for(title)
      clean_title = title.gsub(//)
      clean_title = title
      @imdb.get_movie_at(@imdb.search(clean_title).first.url)
    end
    
    
  end
    
  
end