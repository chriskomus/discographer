class Video < ApplicationRecord
  belongs_to :release

  validates :title, presence: true
  validates :uri, presence: true
end
