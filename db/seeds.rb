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
# Track.destroy_all
# Video.destroy_all

wrapper = Discogs::Wrapper.new('AlbumCatalog')

artists = [22673, 99459, 45, 269, 62447] # shpongle, carbon based lifeforms, aphex twin, squarepusher, younger brother
# labels = [3336, 23528, 925, 25386, 467138] # twisted records, warp records, platipus,  hyperdub, leftfield
labels = [467138] # twisted records, warp records, platipus,  hyperdub, leftfield

# LABELS
# -------

# iterate through each label
labels.each do |id|
  # Get label object
  label = wrapper.get_label(id)

  # Create label in database
  # new_label = Label.upsert(discogs_id: label.id)
  # new_label.name = label.name
  # new_label.profile = label.profile

  new_label = Label.create!(name: label.name,
                            profile: label.profile,
                            discogs_id: label.id)

  # RELEASES
  # --------

  # Get label's releases
  total_count = wrapper.get_labels_releases(id).pagination.items
  label_releases = wrapper.get_labels_releases(id, :page => 1, :per_page => total_count).releases

  # Iterate through a label's releases
  label_releases.each do |r|
    # Get release object
    release = wrapper.get_release(r.id)

    unless release.title.blank?
      # Create release in database
      new_release = Release.create!(title: release.title,
                                    notes: release.notes,
                                    year: release.year,
                                    country: release.country,
                                    discogs_id: release.id)

      # Associate release with label
      new_label.release_ids << new_release.id
      new_label.save

      # ARTISTS
      # -------

      # Get release artists
      release_artists = release.artists

      # Iterate through a release's artists
      release_artists.each do |ra|
        # Get artist object
        artist = wrapper.get_artist(ra.id)

        unless artist.name.blank?
          # Create artist in database
          new_artist = Artist.create!(name: artist.name,
                                      profile: artist.profile,
                                      discogs_id: artist.id)

          # Associate artist with release
          new_release.artist_ids << new_artist.id
          new_release.save

          # Associate artist with label
          new_label.artist_ids << new_artist.id
          new_label.save
        end
      end

      # GENRES
      # -------

      # Get release genres
      release_genres = release.styles

      # Iterate through a release's genres
      release_genres.each do |rg|

        unless rg.blank?
          # Create genre in database
          new_genre = Genre.create!(name: rg)

          # Associate genre with release
          new_release.genre_ids << new_genre.id
          new_release.save
        end

      end
    end

  end
end

# artists.each do |id|
#   artist = wrapper.get_artist(id)
#   artist_image = artist.images.find_all { |img| img.type == 'primary' }[0].uri
#
#   Artist.create!(name: artist.name,
#                  profile: artist.profile,
#                  imageuri: artist_image)
# end

# artist_image = artist.images.find_all { |img| img.type == 'primary' }[0].uri

# total_count = wrapper.get_artist_releases(artist_id).pagination.items
# artist_releases = wrapper.get_artist_releases(artist_id, :page => 1, :per_page => total_count).releases
#
#
# artist_releases.each do |index|
#
# end

p "Created #{Label.count} labels."
p "Created #{Release.count} releases."
p "Created #{Artist.count} artists."
p "Created #{Genre.count} genres."
p "Created #{Track.count} tracks."
p "Created #{Video.count} videos."
