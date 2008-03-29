module Imdb
  require 'rubygems'
  require 'scrapi'
  require 'open-uri'
  require 'uri'
  
  TITLE_RE = /<p><b>Popular Titles<\/b>(.+)<\/p>/i
  IMDB_URL = "http://www.imdb.com"

  class Search    
    def initialize(search_string=nil)
      @cached_html = {}
      if search_string
        search_url = IMDB_URL + "/find?s=tt&q=#{URI.escape(search_string)}"
        puts search_url
        @search_html = open(search_url).read 
        # puts " * Searching IMDB for #{search_string}..."
        @search_results = process_search
      end
    end
  
    def movies(index=nil)
      return "Index Error" unless (index.nil? || (0..(@search_results.size - 1)).to_a.include?(index))
      if index.nil?
        return @search_results
      else
        @movie_results = process_movie(index)
      end
    end
    
    def get_movie_at(url)
      movie_url = IMDB_URL + url
      movie_html = get_url(movie_url)
      return Movie.new(MovieScraper.scrape(movie_html))
    end
    
    def client
      quit = false
      while quit == false
        search = ''
        while search.empty?
          print "Enter a Movie Title => "
          search = gets.chomp!
        end

        if search == 'q'
          quit = true 
          exit
        end

        s = Imdb::Search.new(search)

        quit_lookup = false
        while quit_lookup == false
          if s.movies.empty?
            # puts "No Results Found!\n"
          else
            s.movies.each_with_index do |m,i|
              puts "#{i + 1}. #{m[:name]}"
            end
          end
          print "Select a Title (1-#{s.movies.size}) => "
          mi = (gets.chomp).to_i - 1
          if mi >= 0
            puts s.movies(mi).inspect 
          else
            quit_lookup = true
          end
        end
      end
    end

    private
    
    def process_search
      title_html = preprocess(@search_html,TITLE_RE)
      return SearchScraper.scrape(title_html)
    end
    
    def process_movie(index)
      return get_movie_at(@search_results[index].url)
    end
    
    def preprocess(text,re)
      if (r = text.match(re))
        return r[0]
      end
    end
    
    def get_url(url)
      if (html = @cached_html[url]).nil?
        @cached_html[url] = html = open(url).read
      else
        html = open(url).read
      end
      return html
    end
    
  end    
    
  class Movie
    attr_reader :movie
    
    RATING_RE = /\n+User Rating: ([0-9\.]+)\/10/
    GENRE_RE = /Genre:\n(.*)more/
    SUMMARY_RE = /Plot Outline:\s+(.+)\s+more/
    RUNTIME_RE = /Runtime:\s+([0-9]+)/
    RELEASE_RE = /Release Date:\n(.+) more/
    
    def initialize(scraped_info)
      @movie = scraped_info
    end
    
    def rating
      if (m = @movie.rating.match(RATING_RE))
        return m[1].to_f
      else
        return @movie.rating
      end
    end
    
    def genre
      if (m = @movie.genre.match(GENRE_RE))
        return m[1]#.split(/ \/ /)
      else
        raise "error"
        return @movie.genre
      end
    end
    
    def release
        if (m = @movie.release.match(RELEASE_RE))
          return m[1]#.split(/ \/ /)
        else
          raise "error"
          return @movie.release
        end
      end      
    
    def summary
      if (m = @movie.summary.match(SUMMARY_RE))
        sum = m[1]
        if sum.match(/This plot synopsis is empty/i)
          return "N/A"
        else
          return sum
        end
      else
        return @movie.summary
      end
    end
    
    def runtime
      if (m = @movie.runtime.match(RUNTIME_RE))
        return m[1].to_i
      else
        return @movie.runtime
      end
    end
    
    def method_missing(method_name,*args)
      @movie.send(method_name,*args)
    end
  end  
    
  class FoundMovie <Scraper::Base
      process "td:first-child a img", :img => "@src"
      process "td:last-child a", :url => "@href"
      process "td:last-child a", :name => :text
      result :img, :url, :name
  end
    
  class SearchScraper < Scraper::Base
    array :movies
    process "table tr", :movies => FoundMovie
    result :movies
  end

  class MovieScraper < Scraper::Base
    process "div#tn15title h1", :title => :text
    process "div#tn15rating div.general", :rating => :text
    process "div#tn15main div#tn15content div.info:nth-child(7) a", :director => :text
    process "div#tn15main div#tn15content div.info:nth-child(9)", :release => :text
    process "div#tn15main div#tn15content div.info:nth-child(10)", :genre => :text
    process "div#tn15main div#tn15content div.info:nth-child(12)", :summary => :text
    process "div#tn15main div#tn15content div.info:nth-child(26)", :runtime => :text
    process "div#tn15lhs div.photo img", :image => "@src"
    result :title, :rating, :director, :genre, :release, :summary, :runtime, :image
  end
end