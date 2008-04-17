module Tpb
  require 'rubygems'
  require 'scrapi'
  require 'open-uri'
  require 'uri'
  
  TPB_URL = "http://thepiratebay.org"

  class Search    
    def initialize(search_string=nil)
      @cached_html = {}
      search(search_string) if search_string
    end
  
    def search(search_string)
      search_url = TPB_URL + "/search/#{URI.escape(search_string)}/0/7/200"
      @search_html = open(search_url).read 
      @search_results = process_search
    end
  
    def movies(index=nil)
      return "Index Error" unless (index.nil? || (0..(@search_results.size - 1)).to_a.include?(index))
      if index.nil?
        return @search_results
      else
        @movie_results = process_movie(index)
        return @movie_results
      end
    end
    
    def get_movie_at(url)
      movie_url = TPB_URL + url
      movie_html = get_url(movie_url)
      return Movie.new(MovieScraper.scrape(movie_html))
    end
    
    def browse(limit=100)
      results = []
      page = 1
      while results.size < limit
        browse_html = open(browse_url(page)).read
        results += process_search(browse_html).select{|m| m.category.match("Movies")}
        page += 1
      end
      return results[0..(limit - 1)]
    end

    private
    
    def browse_url(page)
      TPB_URL + "/browse/200/#{[page.to_i,0].max - 1}/7"
    end
    
    def process_search(html=nil)
      html ||= @search_html
      raw_movies = SearchScraper.scrape(html)
      processed_movies = raw_movies.reject{|m| m.name.nil? }.collect{|m| Movie.new(m)}
      return processed_movies
    end
    
    def process_movie(index)
      return get_movie_at(@search_results[index].url)
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
    
    def initialize(scraped_info)
      @movie = scraped_info
    end
    
    def url
      URI.escape(@movie.url).gsub('[',"%5B").gsub(']',"%5D")
    end
    
    def size
      @movie.size.gsub('&nbsp;',' ')
    end
    
    def seeders
      @movie.seeders.to_i
    end
    
    def leechers
      @movie.leechers.to_i
    end
    
    def method_missing(method_name,*args)
        @movie.send(method_name,*args)
    end
  end  
    
  class FoundMovie < Scraper::Base
      process "td:nth-of-type(1)", :category => :text
      process "td:nth-of-type(2) a", :name => :text, :url => "@href"
      process "td:nth-of-type(3)", :uploaded => :text
      process "td:nth-of-type(5)", :size => :text
      process "td:nth-of-type(6)", :seeders => :text
      process "td:nth-of-type(7)", :leechers => :text
      result :category, :name, :url, :uploaded, :size, :seeders, :leechers
  end
    
  class SearchScraper < Scraper::Base
    array :movies
    process "table#searchResult tr", :movies => FoundMovie
    result :movies
  end

  class MovieScraper < Scraper::Base
    process "div#title", :title => :text
    process "div.download a", :torrent => "@href"
    process "div.nfo pre", :info => :text
    process "div#details dl.col1 dd:nth-of-type(3)", :size => :text
    process "div#details dl.col1 dd:nth-of-type(4)", :language => :text
    process "div#details dl.col2 dd:nth-of-type(2)", :uploaded => :text
    process "div#details dl.col2 dd:nth-of-type(4)", :seeders => :text
    process "div#details dl.col2 dd:nth-of-type(5)", :leechers => :text
    result :title, :torrent, :size, :uploaded, :seeders, :leechers, :language, :info
  end
end

# title = "300"
# s = Tpb::Search.new(title)
# puts s.browse(100).inspect