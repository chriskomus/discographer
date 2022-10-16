require "discogs"
user_token = "UVHUjZHYJrClanUtJWdzVCUHXvPdDpwppwPgSyWJ"

def seed_database(user_token)
  clear_database

  artists = [22673, 99459, 45, 269, 62447] # shpongle, carbon based lifeforms, aphex twin, squarepusher, younger brother
  # labels = [3336, 23528, 925, 25386, 467138, 1504] # twisted records, warp records, platipus,  hyperdub, leftfield, ad noiseum
  labels = [467138] # twisted records, warp records, platipus,  hyperdub, leftfield

  # iterate through each label
  labels.each_with_index do |id, i|
    # Create label in database
    new_label = create_or_get_label(id, user_token)

    p "Created #{new_label.name}"

    generate_all_releases_on_label(id, user_token)
  end

  generated_count
end

##
# Generate all releases on a label from Discogs API
def generate_all_releases_on_label(label_id, user_token)
  wrapper = Discogs::Wrapper.new('AlbumCatalog', user_token: user_token)

  # Get label's releases
  page = 1
  per_page = 100
  label_releases = wrapper.get_labels_releases(label_id, :page => page, :per_page => per_page)
  make_request(label_releases, wrapper.get_labels_releases(label_id, :page => page, :per_page => per_page)) # check if Discogs has rate limited the request
  pages = label_releases.pagination.pages

  while page <= pages
    # Get next page of data, this has already been done for the first page, so if page is 1 this is skipped
    unless page == 1
      label_releases = wrapper.get_labels_releases(id, :page => page, :per_page => per_page).releases
      make_request(label_releases, wrapper.get_labels_releases(id, :page => page, :per_page => per_page).releases) # check if Discogs has rate limited the request
    end

    # Iterate through a label's releases
    label_releases.releases.each_with_index do |r, i|
      p "  Processing #{r.title}. Item #{i + 1} of #{label_releases.releases.count}"

      create_or_get_release(r.id, user_token)
    end

    page = page + 1
  end
end

##
# Generate all releases by an artist from Discogs API
def generate_all_releases_by_artist(label_id, user_token) end

##
# Create or get a release from Discogs API
# Take in a Discogs id and create a wrapper object,
# then create an entry in the database
# Add the release to the label, then add the artists and genre to the database
def create_or_get_release(id, user_token)
  wrapper = Discogs::Wrapper.new('AlbumCatalog', user_token: user_token)

  # Get release object
  release = wrapper.get_release(id)
  make_request(release, wrapper.get_release(id)) # check if Discogs has rate limited the request

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

    # Get release's labels and iterate through them, adding to database
    release_labels = release.labels
    release_labels.each_with_index do |rl, i|
      p "    Processing #{rl.name}. Item #{i + 1} of #{release_labels.count}"
      new_label = create_or_get_label(rl.id, user_token)

      # Associate release with label
      add_release_to_label(new_release, new_label)

      # Get release's artists and iterate through them, adding to database
      release_artists = release.artists
      release_artists.each_with_index do |ra, j|
        p "    Processing #{ra.name}. Item #{j + 1} of #{release_artists.count}"
        new_artist = create_or_get_artist(ra.id, user_token)

        # Associate artist with release
        add_artist_to_release(new_artist, new_release)

        # Associate artist with label
        add_artist_to_label(new_artist, new_label)
      end
    end

    # Get release's genres and iterate through them, adding to database
    release_genres = release.styles
    release_genres.each_with_index do |rg, k|
      p "    Processing #{rg}. Item #{k + 1} of #{release_genres.count}"
      new_genre = create_or_get_genre(rg)

      # Associate genre with release
      add_genre_to_release(new_genre, new_release)
    end

    new_release
  end
end

##
# Generate a label from Discogs API
# Take in a Discogs id and create a wrapper object,
# then create an entry in the database
def create_or_get_label(id, user_token)
  wrapper = Discogs::Wrapper.new('AlbumCatalog', user_token: user_token)

  # Get label object
  label = wrapper.get_label(id)
  make_request(label, wrapper.get_label(id)) # check if Discogs has rate limited the request

  # Create label in database
  Label.where(:discogs_id => id).first_or_create { |item|
    item.name = label.name
    item.profile = label.profile
    item.discogs_id = label.id
  }
end

##
# Create or get an artist from Discogs API
# Take in a Discogs id and create a wrapper object,
# then create an entry in the database.
# Then add the artist to the release, and the artist to the label.
def create_or_get_artist(id, user_token)
  wrapper = Discogs::Wrapper.new('AlbumCatalog', user_token: user_token)

  # Get artist object
  artist = wrapper.get_artist(id)
  make_request(artist, wrapper.get_artist(id)) # check if Discogs has rate limited the request

  unless artist.name.blank?
    p "    Adding #{artist.name}"

    # Create artist in database
    Artist.where(:name => artist.name).first_or_create { |item|
      item.name = artist.name
      item.profile = artist.profile
      item.discogs_id = artist.id
    }
  end
end

##
# Create or get a genre from Discogs API
# Take in a Discogs id and create a wrapper object,
# then create an entry in the database.
# Then add the genre to the release.
def create_or_get_genre(genre_name)
  unless genre_name.blank?
    p "    Adding #{genre_name}"

    # Create genre in database
    Genre.where(:name => genre_name).first_or_create { |item|
      item.name = genre_name
    }
  end
end

##
# Create or get a track from Discogs API
# Take in a Discogs id and create a wrapper object,
# then create an entry in the database
def create_or_get_track(release)
  # wrapper = Discogs::Wrapper.new('AlbumCatalog', user_token: "UVHUjZHYJrClanUtJWdzVCUHXvPdDpwppwPgSyWJ")

end

##
# Create or get a video from Discogs API
# Take in a Discogs id and create a wrapper object,
# then create an entry in the database
def create_or_get_video(release)
  # wrapper = Discogs::Wrapper.new('AlbumCatalog', user_token: "UVHUjZHYJrClanUtJWdzVCUHXvPdDpwppwPgSyWJ")

end

##
# Add a release to a label in the database
def add_release_to_label(release, label)
  unless label == nil || release == nil
    label.releases << release unless label.releases.include?(release)
    label.save
  end
end

##
# Add an artist to a release in the database
def add_artist_to_release(artist, release)
  unless artist == nil || release == nil
    release.artists << artist unless release.artists.include?(artist)
    release.save
  end
end

##
# Add an artist to a label in the database
def add_artist_to_label(artist, label)
  unless artist == nil || label == nil
    label.artists << artist unless label.artists.include?(artist)
    label.save
  end
end

##
# Add a genre to a release in the database
def add_genre_to_release(genre, release)
  unless genre == nil || release == nil
    release.genres << genre unless release.genres.include?(genre)
    release.save
  end
end

##
# Put a count of all items in the database
def generated_count
  p "Created #{Label.count} labels."
  p "Created #{Release.count} releases."
  p "Created #{Artist.count} artists."
  p "Created #{Genre.count} genres."
  p "Created #{Track.count} tracks."
  p "Created #{Video.count} videos."
end

##
# Clear the database
def clear_database
  Artist.destroy_all
  Label.destroy_all
  Release.destroy_all
  Genre.destroy_all
  # Track.destroy_all
  # Video.destroy_all
end

##
# Discogs rate limits to 60 requests per minute. If the response message indicates a rate limit
# wait 60 seconds and continue.
def make_request(response, callback)
  if response.message == "You are making requests too quickly."
    sleep(60)
    send(callback)
  end
end

seed_database(user_token)