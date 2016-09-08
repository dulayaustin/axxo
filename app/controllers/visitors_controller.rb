class VisitorsController < ApplicationController
  before_action :set_search

  def index
    @results = @search.result
    @results = @results.valid.recent
    @movies = @results.page(params[:page]).per(15)
  end

  def display
    @movie = Movie.find(params[:id])
  end

  def category
    @category = Category.includes(:movies).find_by(name: params[:name])
    @movies = @category.movies.valid.recent.page(params[:page]).per(15)
  end

  private
    def set_search
      @search = Movie.ransack(params[:q])
    end
end
