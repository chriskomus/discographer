json.extract! release, :id, :year, :title, :country, :notes, :created_at, :updated_at
json.url release_url(release, format: :json)
