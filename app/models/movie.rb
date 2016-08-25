class Movie < ActiveRecord::Base
  has_many :movie_categories
  has_many :categories, through: :movie_categories, source: :category
end
