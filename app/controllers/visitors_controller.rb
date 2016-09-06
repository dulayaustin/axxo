class VisitorsController < ApplicationController
  
  def index
    @movies = Movie.valid.recent.page(params[:page]).per(15)
  end

  def display
    @movie = Movie.find(params[:id])
  end

  def category
    @movies_by_category = Category.includes(:movies).where(id: params[:id])
  end

end
