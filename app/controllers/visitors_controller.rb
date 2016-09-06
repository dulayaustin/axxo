class VisitorsController < ApplicationController
  
  def index
    @movies = Movie.valid.recent.page(params[:page]).per(15)
  end

  def display
    @movie = Movie.find(params[:id])
  end

  def category
    @category = Category.includes(:movies).find_by(id: params[:id])
    @movies = @category.movies.page(params[:page]).per(15)
  end

end
