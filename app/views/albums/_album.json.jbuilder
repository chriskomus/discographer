json.extract! album, :id, :year, :title, :country, :notes, :created_at, :updated_at
json.url album_url(album, format: :json)
