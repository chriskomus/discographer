require "discogs"
require 'logger'
require './app/services/discogs_service.rb'

app_name = "AlbumCatalog"
user_token = "UVHUjZHYJrClanUtJWdzVCUHXvPdDpwppwPgSyWJ"

# Seed data
artists = []
labels = [467138]

wrapper = Discogs::Wrapper.new(app_name, user_token: user_token)
discogs_service = DiscogsService.new(wrapper)

# discogs_service.clear_database(true)
#
discogs_service.seed_database(artists, labels)
discogs_service.log_generated_count
discogs_service.log_database_count