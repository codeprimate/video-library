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
    
    def get_list(limit=100)
      @tpb_list ||= @tpb.browse(limit) 
    end
    
    def imdb_entry_for(title)
      clean_title = title.gsub(/\[[^\]]+\]/,'').gsub(/\W/,' ').gsub(/dvdrip/,'')
      @imdb.get_movie_at(@imdb.search(clean_title).first.url)
    end
    
    
    
  end
    
  
end