# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
require "discogs"

Artist.destroy_all
Label.destroy_all
Release.destroy_all
Genre.destroy_all
Track.destroy_all
Video.destroy_all

wrapper = Discogs::Wrapper.new('AlbumCatalog')

arr = [22673, 99459, 45, 269] # shpongle, carbon based lifeforms, aphex twin, squarepusher
artist_id = arr[3]

artist = wrapper.get_artist(artist_id)
p artist

# artist_image = artist.images.find_all { |img| img.type == 'primary' }[0].uri

# total_count = wrapper.get_artist_releases(artist_id).pagination.items
# artist_releases = wrapper.get_artist_releases(artist_id, :page => 1, :per_page => total_count).releases
#
#
# artist_releases.each do |index|
#
# end

p "Created #{Artist.count} artists."