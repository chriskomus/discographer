require "discogs"
require 'logger'
require 'tmpdir'
user_token = "UVHUjZHYJrClanUtJWdzVCUHXvPdDpwppwPgSyWJ"

##
# This class represents the import functions to bring data from Discogs' API
# and save it to the database.
class ImportDiscogs
  def initialize(user_token)
    # Set user token and discogs wrapper
    @user_token = user_token
    @wrapper = Discogs::Wrapper.new('AlbumCatalog', user_token: @user_token)

    # Create logging
    log_file = "log/debug.log"
    @log = Logger.new(STDOUT, log_file)
    @log.level = Logger::DEBUG
  end

  ##
  # Seed the database with all Albums from an array of artists or an array of labels
  # @param artists - An array of Discogs Artist id #s
  # @param labels - An array of Discogs Label id #s
  # @param dump_data - If true the entire database will be cleared before seeding
  def seed_database(artists, labels)
    # iterate through each label
    labels.each_with_index do |id, i|
      new_label = create_or_get_label(id)
      @log.debug "[Processing Label] #{new_label.name}. Item #{i + 1} of #{labels.count}"
      generate_all_albums_on_label(id)
    end

    # iterate through each artist
    artists.each_with_index do |id, i|
      new_artist = create_or_get_artist(id)
      @log.debug "[Processing Artist] #{new_artist.name}. Item #{i + 1} of #{artists.count}"
      generate_all_albums_by_artist(id)
    end

    generated_count

    @log.info "[ALL DONE!] Successfully imported #{labels.count} labels, and #{artists.count} artists."
  end

  ##
  # Generate all Albums on a label from Discogs API
  def generate_all_albums_on_label(label_id)
    # Get label's Albums
    page = 1
    per_page = 100
    req_method = @wrapper.method(:get_labels_releases)
    label_albums = make_request(req_method, label_id, { :page => page, :per_page => per_page })
    pages = label_albums.pagination.pages

    while page <= pages
      # Get next page of data, this has already been done for the first page, so if page is 1 this is skipped
      unless page == 1
        label_albums = make_request(req_method, label_id, { :page => page, :per_page => per_page })
      end

      # Iterate through a label's Albums
      label_albums.releases.each_with_index do |r, i|

        # Check if the release already exists before adding to the database
        if Release.exists?(catno: r.catno)
          @log.debug "[Duplicate Album] #{r.title}. Item #{i + 1} of #{label_albums.releases.count}"
        else
          @log.debug "[Processing Album] #{r.title}. Item #{i + 1} of #{label_albums.releases.count}"
          create_or_get_album(r.id)
        end
      end

      page = page + 1
    end
  end

  ##
  # Generate all Albums by an artist from Discogs API
  def generate_all_albums_by_artist(artist_id)
    # Get artist's Albums
    page = 1
    per_page = 100
    req_method = @wrapper.method(:get_artist_releases)
    artist_albums = make_request(req_method, artist_id, { :page => page, :per_page => per_page })
    pages = artist_albums.pagination.pages

    while page <= pages
      # Get next page of data, this has already been done for the first page, so if page is 1 this is skipped
      unless page == 1
        artist_albums = make_request(req_method, artist_id, { :page => page, :per_page => per_page })
      end

      # Iterate through an artist's Albums
      artist_albums.releases.each_with_index do |r, i|
        @log.debug "[Processing Album] #{r.title}. Item #{i + 1} of #{artist_albums.releases.count}"

        create_or_get_album(r.id)
      end

      page = page + 1
    end
  end

  ##
  # Create or get a album from Discogs API
  # Take in a Discogs id and create a wrapper object,
  # then create an entry in the database
  # Add the album to the label, then add the artists and genre to the database
  # @param discogs_id: The discogs ID of a discog release
  def create_or_get_album(discogs_id)
    # Get album object
    # album = wrapper.get_release(id)
    # album = make_request(:wrapper.get_release(id))
    req_method = @wrapper.method(:get_release)
    album = make_request(req_method, discogs_id)

    unless album.title.blank?
      @log.info "[Adding Album] #{album.title} - #{album.discogs_id}"

      # Create album in database
      new_album = Album.where(:title => album.title).first_or_create { |item|
        item.title = album.title
        item.notes = album.notes
        item.year = album.year
        item.country = album.country
        item.discogs_id = album.id
      }

      # Get album's labels and iterate through them, adding to database
      album_labels = album.labels
      album_labels.each_with_index do |al, i|
        # Check if the label already exists
        if Label.exists?(name: al.name)
          @log.debug "[Duplicate Label] #{al.name}. Item #{i + 1} of #{album_labels.count}"
          new_label = Label.where(name: al.name).first
        else
          @log.debug "[Processing Label] #{al.name}. Item #{i + 1} of #{album_labels.count}"
          new_label = create_or_get_label(al.id)
        end

        # Associate album with label
        add_album_to_label(new_album, new_label)

        # Associate album with release - add a catalog number for this label's release of this album
        add_album_to_release(new_album, new_label, al.catno)

        # Get album's artists and iterate through them, adding to database
        album_artists = album.artists
        album_artists.each_with_index do |aa, j|
          # Check if the artist already exists
          if Artist.exists?(name: aa.name)
            @log.debug "[Duplicate Artist] #{aa.name}. Item #{j + 1} of #{album_artists.count}"
          else
            @log.debug "[Processing Artist] #{aa.name}. Item #{j + 1} of #{album_artists.count}"
            new_artist = create_or_get_artist(aa.id)

            # Associate artist with album
            add_artist_to_album(new_artist, new_album)

            # Associate artist with label
            add_artist_to_label(new_artist, new_label)
          end
        end

      end

      # Get album's genres and iterate through them, adding to database
      album_genres = album.styles
      album_genres.each_with_index do |ag, i|
        if Genre.exists?(name: ag)
          @log.debug "[Duplicate Genre] #{ag}. Item #{i + 1} of #{album_genres.count}"
        else
          @log.debug "[Processing Genre] #{ag}. Item #{i + 1} of #{album_genres.count}"
          new_genre = create_or_get_genre(ag)

          # Associate genre with album
          add_genre_to_album(new_genre, new_album)
        end
      end

      # Get album's videos and iterate through them, adding to database
      album_videos = album.videos
      if album_videos
        album_videos.each_with_index do |av, i|
          if Video.exists?(:album => new_album, :title => av.title, :uri => av.uri)
            @log.debug "[Duplicate Video] #{av.title}. Item #{i + 1} of #{album_videos.count}"
          else
            @log.debug "[Processing Video] #{av.title}. Item #{i + 1} of #{album_videos.count}"
            create_or_get_video(new_album, av)
          end
        end
      end

      # Get album's tracks and iterate through them, adding to database
      album_tracks = album.tracklist
      if album_tracks
        album_tracks.each_with_index do |at, i|
          if Track.exists?(:album => new_album, :title => at.title, :position => at.position)
            @log.debug "[Duplicate Track] #{at.title}. Item #{i + 1} of #{album_tracks.count}"
          else
            @log.debug "[Processing Track] #{at.title}. Item #{i + 1} of #{album_tracks.count}"
            create_or_get_track(new_album, at)
          end
        end
      end

      new_album
    end
  end

  ##
  # Generate a label from Discogs API
  # Take in a Discogs id and create a wrapper object,
  # then create an entry in the database
  # @param discogs_id: The discogs ID of a label
  def create_or_get_label(discogs_id)
    req_method = @wrapper.method(:get_label)
    label = make_request(req_method, discogs_id)

    unless label.name.blank?
      @log.info "[Adding Label] #{label.name} - #{label.discogs_id}"

      # Create label in database
      Label.where(:discogs_id => discogs_id).first_or_create { |item|
        item.name = label.name
        item.profile = label.profile
        item.discogs_id = label.id
      }
    end
  end

  ##
  # Create or get an artist from Discogs API
  # Take in a Discogs id and create a wrapper object,
  # then create an entry in the database.
  # Then add the artist to the album, and the artist to the label.
  # @param discogs_id: The discogs ID of a label
  def create_or_get_artist(discogs_id)
    req_method = @wrapper.method(:get_artist)
    artist = make_request(req_method, discogs_id)

    unless artist.name.blank?
      @log.info "[Adding Artist] #{artist.name} - #{artist.discogs_id}"

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
  # Then add the genre to the album.
  def create_or_get_genre(genre_name)
    unless genre_name.blank?
      @log.info "[Adding Genre] #{genre_name}"

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
  # @param album: an object derived from an Album model
  # @param track: A single track from the .tracklist array in Discogs's releases endpoint
  def create_or_get_track(album, track)
    unless track == nil || album == nil
      @log.info "[Adding Track] #{track.title}"

      # Create track in database
      Track.where(:album => album, :title => track.title, :position => track.position).first_or_create { |item|
        item.album = album
        item.position = track.position
        item.title = track.title
        item.duration = track.duration
      }
    end
  end

  ##
  # Create or get a video from Discogs API
  # Take in a Discogs id and create a wrapper object,
  # then create an entry in the database
  # @param album: an object derived from an Album model
  # @param video: A single video from the .videos array in Discogs's releases endpoint
  def create_or_get_video(album, video)
    unless video == nil || album == nil
      @log.info "[Adding Video] #{video.title}"

      # Create video in database
      Video.where(:album => album, :title => video.title, :uri => video.uri).first_or_create { |item|
        item.album = album
        item.title = video.title
        item.uri = video.uri
        item.description = video.description
      }
    end
  end

  ##
  # Add a album to a label in the database
  def add_album_to_label(album, label)
    unless label == nil || album == nil
      label.albums << album unless label.albums.include?(album)
      label.save
    end
  end

  ##
  # Add a album to a release in the database
  # This is necessary to differential between an album and release, because there is only one single
  # body of work per album (ie: album, ep, lp) and an album can be released many times on different labels, or
  # re-released on the same label with a different catalog no.
  # This will only add a new record if there isn't already a matching catno in the database.
  def add_album_to_release(album, label, catno)
    unless label == nil || album == nil
      Release.where(:catno => catno).first_or_create { |item|
        item.album = album
        item.label = label
        item.catno = catno
      }
    end
  end

  ##
  # Add an artist to a album in the database
  def add_artist_to_album(artist, album)
    unless artist == nil || album == nil
      album.artists << artist unless album.artists.include?(artist)
      album.save
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
  # Add a genre to a album in the database
  def add_genre_to_album(genre, album)
    unless genre == nil || album == nil
      album.genres << genre unless album.genres.include?(genre)
      album.save
    end
  end

  ##
  # Put a count of all items in the database
  def generated_count
    @log.info "Database contains #{Label.count} labels."
    @log.info "Database contains #{Album.count} albums."
    @log.info "Database contains #{Release.count} releases."
    @log.info "Database contains #{Artist.count} artists."
    @log.info "Database contains #{Genre.count} genres."
    @log.info "Database contains #{Track.count} tracks."
    @log.info "Database contains #{Video.count} videos."
  end

  ##
  # Clear the database
  def clear_database(reset_id_nums = false)
    Artist.destroy_all
    Label.destroy_all
    Album.destroy_all
    Genre.destroy_all
    Video.destroy_all
    # Track.destroy_all
    #
    @log.warn "Database has been cleared."

    # Reset IDs
    if reset_id_nums
      ActiveRecord::Base.connection.execute("DELETE from sqlite_sequence where name = 'artists'")
      ActiveRecord::Base.connection.execute("DELETE from sqlite_sequence where name = 'labels'")
      ActiveRecord::Base.connection.execute("DELETE from sqlite_sequence where name = 'albums'")
      ActiveRecord::Base.connection.execute("DELETE from sqlite_sequence where name = 'genres'")
      ActiveRecord::Base.connection.execute("DELETE from sqlite_sequence where name = 'videos'")
      # ActiveRecord::Base.connection.execute("DELETE from sqlite_sequence where name = 'tracks'")
      @log.warn "Table Primary Key IDs have been reset."
    end
  end

  ##
  # Make a request to the Discogs wrapper by passing the wrapper method (ie: get_label)
  # and the arguments (ie: id) for that method as params to this method. This method then calls the
  # provided wrapper method with it's argument(s) and makes the request and return the response.
  # If a rate limit error is returned, pause for 60 seconds and call the wrapper method again.
  # Note: Discogs rate limits to 60 requests per minute for authorized requests.
  def make_request(meth, *args)
    # response = callback.(id)
    response = meth.call(*args)

    # check if Discogs has rate limited the request
    if response.message == "You are making requests too quickly."
      @log.warn "Rate Limit Exceeded: Discogs rate limits to 60 requests per minute."
      @log.info "Waiting 60 seconds and continuing..."
      sleep(60)
      # response = callback.(id)
      response = meth.call(*args)
    end

    response
  end
end

##
# This class is a psuedo IO class that will write to multiple IO objects for logging to both a log file and console
class MultiIO
  def initialize(*targets)
    @targets = targets
  end

  def write(*args)
    @targets.each { |t| t.write(*args) }
  end

  def close
    @targets.each(&:close)
  end
end

# Seed data
artists = [22673, 99459, 45, 269, 62447] # shpongle, carbon based lifeforms, aphex twin, squarepusher, younger brother
labels = [3336, 925, 25386, 1504, 467138] # twisted records, platipus,  hyperdub, leftfield, ad noiseum, leftfield

# Test data
artists = []
labels = [467138]

import_discogs = ImportDiscogs.new(user_token)

# import_discogs.clear_database(true)

import_discogs.seed_database(artists, labels)