class Video < ApplicationRecord
  belongs_to :album

  validates :title, presence: true
  validates :uri, presence: true
end
