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
labels.each_with_index  do |id, i|
  # Get label object
  label = wrapper.get_label(id)

  p "Processing #{label.name}. Item #{i} of #{labels.count}"

  # Create label in database
  new_label = Label.where(:discogs_id => id).first_or_create { |item|
    item.name = label.name
    item.profile = label.profile
    item.discogs_id = label.id
  }

  # RELEASES
  # --------

  # Get label's releases
  total_count = wrapper.get_labels_releases(id).pagination.items
  label_releases = wrapper.get_labels_releases(id, :page => 1, :per_page => total_count).releases

  # Iterate through a label's releases
  label_releases.each_with_index  do |r, j|
    p "  Processing #{r.title}. Item #{j} of #{label_releases.count}"

    # Get release object
    release = wrapper.get_release(r.id)

    unless release.title.blank?
      p "  Adding #{release.title}"

      # Create release in database
      new_release = Release.where(:title => release.title).first_or_create { |item|
        item.title = release.title
        item.notes = release.notes
        item.year = release.year
        item.country = release.country
        item.catalog_num = release.catno
        item.discogs_id = release.id
      }

      # Associate release with label
      new_label.releases << new_release unless new_label.releases.include?(new_release)
      new_label.save

      # ARTISTS
      # -------

      # Get release artists
      release_artists = release.artists

      # Iterate through a release's artists
      release_artists.each_with_index  do |ra, k|
        p "    Processing #{ra.name}. Item #{k} of #{release_artists.count}"

        # Get artist object
        artist = wrapper.get_artist(ra.id)

        unless artist.name.blank?
          p "    Adding #{artist.name}"

          # Create artist in database
          new_artist = Artist.where(:name => artist.name).first_or_create { |item|
            item.name = artist.name
            item.profile = artist.profile
            item.discogs_id = artist.id
          }

          # Associate artist with release
          new_release.artists << new_artist unless new_release.artists.include?(new_artist)
          new_release.save

          # Associate artist with label
          new_label.artists << new_artist unless new_label.artists.include?(new_artist)
          new_label.save
        end
      end

      # GENRES
      # -------

      # Get release genres
      release_genres = release.styles

      # Iterate through a release's genres
      release_genres.each_with_index  do |rg, l|
        p "    Processing #{rg}. Item #{l} of #{release_genres.count}"

        unless rg.blank?
          p "    Adding #{rg}"

          # Create genre in database
          new_genre = Genre.where(:name => rg).first_or_create { |item|
            item.name = rg
          }

          # Associate genre with release
          new_release.genres << new_genre unless new_release.genres.include?(new_genre)
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
