class VisitorsController < ApplicationController
  before_action :set_search

  def index
    @results = @search.result
    @results = @results.valid.recent.rating_not_null
    @movies = @results.page(params[:page]).per(15)
  end

  def display
    @movie = Movie.find(params[:id])
  end

  def category
    @category = Category.includes(:movies).find_by(name: params[:name])
    @search = @category.movies.ransack(params[:q])
    @results = @search.result.valid.recent.rating_not_null
    @movies = @results.page(params[:page]).per(15)
  end

  def download
    movie = Movie.find(params[:id])
    movie.count
    redirect_to movie.torrent
  end

  private
    def set_search
      @search = Movie.ransack(params[:q])
    end
end
