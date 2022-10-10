json.extract! video, :id, :title, :uri, :description, :created_at, :updated_at
json.url video_url(video, format: :json)
