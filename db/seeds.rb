require "discogs"
require 'logger'
require './app/services/discogs_service.rb'

user_token = "UVHUjZHYJrClanUtJWdzVCUHXvPdDpwppwPgSyWJ"

# Seed data
artists = [22673, 99459, 45, 269, 62447, 1028023] # shpongle, carbon based lifeforms, aphex twin, squarepusher, younger brother, igorrr
labels = [3336, 925, 25386, 1504, 467138] # twisted records, platipus,  hyperdub, ad noiseum, leftfield

# Test data
artists = [27862]
labels = []

wrapper = Discogs::Wrapper.new('AlbumCatalog', user_token: user_token)
discogs_service = DiscogsService.new(wrapper)

# discogs_service.clear_database(true)
discogs_service.seed_database(artists, labels)
discogs_service.log_generated_count
discogs_service.log_database_count
#
# discogs_service.generate_all_imageuris