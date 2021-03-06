class MoviesController < ApplicationController
  layout 'main'
  
  before_filter :authenticate, :except => [:index, :show]
  
  def index
    @order = sort = (params[:order] || 'title')
    order = validated_sort(sort)
    @tags = Tag.find(:all)
    if (@tag = params[:tag]) and (params[:tag] != "all")
      @movies = Movie.find_tagged_with([@tag], :order => order)
    else
      @movies = Movie.find(:all, :order => order)
    end
    @page_title = "Movie Catalog"
  end
  
  def print_view
    render :layout => 'print_view'
    @order = sort = (params[:order] || 'title')
    order = validated_sort(sort)
    @movies = Movie.find(:all, :order => order)
  end
  
  def new
    @movie = Movie.new
    @page_title = "Add Movie to Collection"
  end
  
  def destroy
    Movie.destroy(params[:id])
    redirect_to movies_path
  end
  
  def edit
    @movie = Movie.find(params[:id])
    @genres = @movie.tag_list
    @page_title = "Edit Movie Entry"
  end

  
  def create
    @movie = Movie.new(params[:movie])
    if @movie.save
      @genres = params[:movie][:genres]
      @movie.tag_list = @genres
      @movie.save
      redirect_to movies_path
    else
      render :action => 'new'
    end
  end
  
  def update
    @movie = Movie.find(params[:id])
    tags = params[:movie][:genres]
    @movie.update_attributes(params[:movie])
    @movie.tag_list = tags
    @movie.save
    redirect_to movies_path
  end
  
  def show 
    @movie = Movie.find(params[:id])
    @page_title = @movie.title
  end
  
  def remote_search_movies
    @search_string = params[:search][:text]
    i_search = Imdb::Search.new(@search_string)
    @search_results = i_search.movies[0..9]
#    rescue
#      @search_results = []
#    ensure
    respond_to do |format|
      format.js
    end
  end
  
  def remote_select_search_result
    url = params[:url]
    i_search = Imdb::Search.new(@search_string)
    movie_data = i_search.get_movie_at(url)
    @movie = Movie.new( 
                        :title => movie_data.title,
                        :summary => movie_data.summary,
                        :director => movie_data.director,
                        :release => movie_data.release,
                        :image_url => movie_data.image,
                        :runtime => movie_data.runtime,
                        :rating => movie_data.rating
                      )
    @genres = movie_data.genre.split(' / ').collect{|g| g.downcase}.join(', ')
    respond_to do |format|
      format.js
    end
  end
  
  private
  
  def validated_sort(in_sort)
    case in_sort
      when 'title'
        order = 'asc'
        sort = 'title'
      when 'newest'
        order = 'desc'
        sort = 'created_at'
      when 'rating'
        order = 'desc'
        sort = 'rating'
      else
        order = sort = nil
    end
    return [sort,order].join(' ')
  end
    
    
  
end
