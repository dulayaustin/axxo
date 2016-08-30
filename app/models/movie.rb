class Movie < ActiveRecord::Base
  has_many :movie_categories
  has_many :categories, through: :movie_categories, source: :category

  scope :without_info, -> {where(torrent: nil)}

  validates :image, allow_blank: true, format: {
    with: %r{\.(gif|png|jpg|jpeg)\Z}i,
    message: 'must be a URL for GIF, PNG, JPG image'
  }
end
