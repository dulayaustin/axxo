class VisitorsController < ApplicationController
  before_action :set_movie, only: :display
  
  def index
    @movies = Movie.valid.page(params[:page]).per(15)
  end

  def display
    
  end

  private
    def set_movie
      @movie = Movie.find(params[:id])
    end
end
