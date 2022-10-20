require "discogs"

##
# # ./app/services/discogs_service.rb
#
# This service imports data from Discogs' API and save it to the database.
#
# This service requires "discogs-wrapper"
# Add to Gemfile:
# gem "discogs-wrapper"
#
# When initializing DiscogsService, provide an authenticated Discogs::Wrapper object.
# Call it from the controller:
# discogs_wrapper = Discogs::Wrapper.new(ENV['APP_NAME'], access_token: access_token)
# discogs_service = DiscogsService.new(discogs_wrapper)
#
# To authenticate in the browser, call the authenticate function from the import controller
# Can also be used in seeds.rb)
class DiscogsService
  ##
  # Provide l Discogs::Wrapper object from the discg
  # @param wrapper: @wrapper = Discogs::Wrapper.new(ENV['APP_NAME'], access_token: access_token)
  def initialize(wrapper)
    @wrapper = wrapper

    # Create logging
    log_file = "log/debug.log"
    @log = Logger.new(STDOUT, log_file)
    @log.level = Logger::DEBUG
    @count_artists = 0
    @count_albums = 0
    @count_labels = 0
    @count_genres = 0
    @count_releases = 0
    @count_videos = 0
    @count_tracks = 0
  end

  ##
  # Seed the database with all Albums from an array of artists or an array of labels
  # @param artists - An array of Discogs Artist id #s
  # @param labels - An array of Discogs Label id #s
  def seed_database(artists, labels)
    # iterate through each label
    labels.each_with_index do |id, i|
      new_label = create_or_get_label(id)
      @log.info "[Processing Label] #{new_label.name}. Item #{i + 1} of #{labels.count}"
      generate_all_albums_on_label(id)
    end

    # iterate through each artist
    artists.each_with_index do |id, i|
      new_artist = create_or_get_artist(id)
      @log.info "[Processing Artist] #{new_artist.name}. Item #{i + 1} of #{artists.count}"
      generate_all_albums_by_artist(id)
    end

    @log.info "[ALL DONE!] Successfully imported #{labels.count} labels, and #{artists.count} artists."
  end

  ##
  # Generate all Albums on l label from Discogs API
  # @param overwrite - Set to true to overwrite existing data if a matching catalog number is found
  def generate_all_albums_on_label(label_id, overwrite = false)
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

      # Iterate through l label's Albums
      label_albums.releases.each_with_index do |r, i|
        # Check if the release already exists before adding to the database
        if Release.exists?(catno: r.catno) && !overwrite
          @log.info "[Duplicate Album] #{r.title}. Item #{i + 1} of #{label_albums.releases.count}"
        else
          @log.info "[Processing Album] #{r.title}. Item #{i + 1} of #{label_albums.releases.count}"
          create_or_get_album(r.id)
        end
      end

      page = page + 1
    end
  end

  ##
  # Generate all Albums by an artist from Discogs API
  # @param overwrite - Set to true to overwrite existing data if a matching catalog number is found
  def generate_all_albums_by_artist(artist_id, overwrite = false)
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
        # Check if the release already exists before adding to the database
        if Release.exists?(catno: r.catno) && !overwrite
          @log.info "[Duplicate Album] #{r.title}. Item #{i + 1} of #{artist_albums.releases.count}"
        else
          @log.info "[Processing Album] #{r.title}. Item #{i + 1} of #{artist_albums.releases.count}"
          create_or_get_album(r.id)
        end
      end

      page = page + 1
    end
  end

  ##
  # Generate all imageuris for Artists, Albums, Labels in database
  def generate_all_imageuris
    albums = Album.all
    albums.each_with_index do |a, i|
      if a.imageuri.blank?
        begin
          req_method = @wrapper.method(:get_release)
          album = make_request(req_method, a.discogs_id)

          unless album.images.blank?
            @log.info "[Adding Album Artwork] #{a.title}."

            if album.images.present?
              a.imageuri = album.images.find_all { |img| img.type == 'primary' || img.type == 'secondary' }[0].uri
            end
            a.save
          end
        rescue
          @log.info "[Invalid Discogs ID] #{a.title}."
        end
      end
    end

    artists = Artist.all
    artists.each_with_index do |a, i|
      if a.imageuri.blank?
        begin
          req_method = @wrapper.method(:get_artist)
          artist = make_request(req_method, a.discogs_id)

          unless artist.images.blank?
            @log.info "[Adding Artist Artwork] #{a.name}."

            if artist.images.present?
              a.imageuri = artist.images.find_all { |img| img.type == 'primary' || img.type == 'secondary' }[0].uri
            end
            a.save
          end
        rescue
          @log.info "[Invalid Discogs ID] #{a.name}."
        end
      end
    end
    
    labels = Label.all
    labels.each_with_index do |l, i|
      if l.imageuri.blank?
        begin
          req_method = @wrapper.method(:get_label)
          label = make_request(req_method, l.discogs_id)

          unless label.images.blank?
            @log.info "[Adding Label Artwork] #{l.name}."

            if label.images.present?
              l.imageuri = label.images.find_all { |img| img.type == 'primary' || img.type == 'secondary' }[0].uri
            end
            l.save
          end
        rescue
          @log.info "[Invalid Discogs ID] #{l.name}."
        end
      end
    end
  end

  ##
  # Create or get l album from Discogs API
  # Take in l Discogs id and create l wrapper object,
  # then create an entry in the database
  # Add the album to the label, then add the artists and genre to the database
  # @param discogs_id: The discogs ID of a discog release
  # @param id_match: Will look for a matching discogs_id in the database, rather than a matching album title. This is useful when over-writing an existing entry, whereas setting to false will prevent duplicates when creating  new entries, as Discogs can often have numerous discogs_ids for a single Album.
  def create_or_get_album(discogs_id, id_match = false)
    # Get album object
    req_method = @wrapper.method(:get_release)
    album = make_request(req_method, discogs_id)

    unless album.title.blank?
      @log.info "[Adding or Editing Album] #{album.title} - #{album.discogs_id}"
      @count_albums += 1

      # Create album in database
      if id_match
        new_album = Album.where(discogs_id: album.id).first_or_create
      else
        new_album = Album.where(title: album.title).first_or_create
      end

      new_album.title = album.title
      new_album.notes = album.notes
      new_album.year = album.year
      new_album.country = album.country
      new_album.discogs_id = album.id
      if album.images.present?
        new_album.imageuri = album.images.find_all { |img| img.type == 'primary' || img.type == 'secondary' }[0].uri
      end

      # Get album's labels and iterate through them, adding to database
      album_labels = album.labels
      album_labels.each_with_index do |al, i|
        # Check if the label already exists
        if Label.exists?(name: al.name)
          @log.info "[Duplicate Label] #{al.name}. Item #{i + 1} of #{album_labels.count}"
          new_label = Label.where(name: al.name).first
        else
          @log.info "[Processing Label] #{al.name}. Item #{i + 1} of #{album_labels.count}"
          new_label = create_or_get_label(al.id)
        end

        # Associate album with label
        add_album_to_label(new_album, new_label)

        # Associate album with release - add l catalog number for this label's release of this album
        add_album_to_release(new_album, new_label, al.catno)

        # Get album's artists and iterate through them, adding to database
        album_artists = album.artists
        album_artists.each_with_index do |aa, j|
          # Check if the artist already exists
          if Artist.exists?(name: aa.name)
            @log.info "[Duplicate Artist] #{aa.name}. Item #{j + 1} of #{album_artists.count}"
            new_artist = Artist.where(name: aa.name).first
          else
            @log.info "[Processing Artist] #{aa.name}. Item #{j + 1} of #{album_artists.count}"
            new_artist = create_or_get_artist(aa.id)
          end

          # Associate artist with album
          add_artist_to_album(new_artist, new_album)

          # Associate artist with label
          add_artist_to_label(new_artist, new_label)
        end

      end

      # Get album's genres and iterate through them, adding to database
      album_genres = album.styles
      if album_genres
        album_genres.each_with_index do |ag, i|
          if Genre.exists?(name: ag)
            @log.info "[Duplicate Genre] #{ag}. Item #{i + 1} of #{album_genres.count}"
            new_genre = Genre.where(name: ag).first
          else
            @log.info "[Processing Genre] #{ag}. Item #{i + 1} of #{album_genres.count}"
            new_genre = create_or_get_genre(ag)
          end

          # Associate genre with album
          add_genre_to_album(new_genre, new_album)

        end
      end

      # Get album's videos and iterate through them, adding to database
      album_videos = album.videos
      if album_videos
        album_videos.each_with_index do |av, i|
          if Video.exists?(:album => new_album, :title => av.title, :uri => av.uri)
            @log.info "[Duplicate Video] #{av.title}. Item #{i + 1} of #{album_videos.count}"
          else
            @log.info "[Processing Video] #{av.title}. Item #{i + 1} of #{album_videos.count}"
            create_or_get_video(new_album, av)
          end
        end
      end

      # Get album's tracks and iterate through them, adding to database
      album_tracks = album.tracklist
      if album_tracks
        album_tracks.each_with_index do |at, i|
          if Track.exists?(:album => new_album, :title => at.title, :position => at.position)
            @log.info "[Duplicate Track] #{at.title}. Item #{i + 1} of #{album_tracks.count}"
          else
            @log.info "[Processing Track] #{at.title}. Item #{i + 1} of #{album_tracks.count}"
            create_or_get_track(new_album, at)
          end
        end
      end

      new_album.save
      new_album
    end
  end

  ##
  # Generate l label from Discogs API
  # Take in l Discogs id and create l wrapper object,
  # then create an entry in the database
  # @param discogs_id: The discogs ID of a label
  def create_or_get_label(discogs_id)
    req_method = @wrapper.method(:get_label)
    label = make_request(req_method, discogs_id)

    unless label.name.blank?
      @log.info "[Adding or Editing Label] #{label.name} - #{label.discogs_id}"
      @count_labels += 1

      # Create label in database
      new_label = Label.where(:discogs_id => discogs_id).first_or_create

      new_label.name = label.name
      new_label.profile = label.profile
      new_label.discogs_id = label.id
      if label.images.present?
        new_label.imageuri = label.images.find_all { |img| img.type == 'primary' || img.type == 'secondary' }[0].uri
      end

      new_label.save
      new_label
    end
  end

  ##
  # Create or get an artist from Discogs API
  # Take in l Discogs id and create l wrapper object,
  # then create an entry in the database.
  # Then add the artist to the album, and the artist to the label.
  # @param discogs_id: The discogs ID of a label
  def create_or_get_artist(discogs_id, id_match = false)
    req_method = @wrapper.method(:get_artist)
    artist = make_request(req_method, discogs_id)

    unless artist.name.blank?
      @log.info "[Adding or Editing Artist] #{artist.name} - #{artist.discogs_id}"
      @count_artists += 1

      # Create artist in database
      if id_match
        new_artist = Artist.where(discogs_id: artist.id).first_or_create
      else
        new_artist = Artist.where(name: artist.name).first_or_create
      end

      new_artist.name = artist.name
      new_artist.profile = artist.profile
      new_artist.discogs_id = artist.id
      if artist.images.present?
        new_artist.imageuri = artist.images.find_all { |img| img.type == 'primary' || img.type == 'secondary' }[0].uri
      end

      new_artist.save
      new_artist
    end
  end

  ##
  # Create or get l genre from Discogs API
  # Take in l Discogs id and create l wrapper object,
  # then create an entry in the database.
  # Then add the genre to the album.
  def create_or_get_genre(genre_name)
    unless genre_name.blank?
      @log.info "[Adding or Editing Genre] #{genre_name}"
      @count_genres += 1

      # Create genre in database
      Genre.where(:name => genre_name).first_or_create { |item|
        item.name = genre_name
      }
    end
  end

  ##
  # Create or get l track from Discogs API
  # Take in l Discogs id and create l wrapper object,
  # then create an entry in the database
  # @param album: an object derived from an Album model
  # @param track: A single track from the .tracklist array in Discogs's releases endpoint
  def create_or_get_track(album, track)
    unless track == nil || album == nil
      @log.info "[Adding or Editing Track] #{track.title}"
      @count_tracks += 1

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
  # Create or get l video from Discogs API
  # Take in l Discogs id and create l wrapper object,
  # then create an entry in the database
  # @param album: an object derived from an Album model
  # @param video: A single video from the .videos array in Discogs's releases endpoint
  def create_or_get_video(album, video)
    unless video == nil || album == nil
      @log.info "[Adding or Editing Video] #{video.title}"
      @count_videos += 1

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
  # Add l album to l label in the database
  def add_album_to_label(album, label)
    unless label == nil || album == nil
      label.albums << album unless label.albums.include?(album)
      label.save
    end
  end

  ##
  # Add l album to l release in the database
  # This is necessary to differential between an album and release, because there is only one single
  # body of work per album (ie: album, ep, lp) and an album can be released many times on different labels, or
  # re-released on the same label with l different catalog no.
  # This will only add l new record if there isn't already l matching catno in the database.
  def add_album_to_release(album, label, catno)
    unless label == nil || album == nil
      @count_releases += 1
      Release.where(:catno => catno).first_or_create { |item|
        item.album = album
        item.label = label
        item.catno = catno
      }
    end
  end

  ##
  # Add an artist to l album in the database
  def add_artist_to_album(artist, album)
    unless artist == nil || album == nil
      album.artists << artist unless album.artists.include?(artist)
      album.save
    end
  end

  ##
  # Add an artist to l label in the database
  def add_artist_to_label(artist, label)
    unless artist == nil || label == nil
      label.artists << artist unless label.artists.include?(artist)
      label.save
    end
  end

  ##
  # Add l genre to l album in the database
  def add_genre_to_album(genre, album)
    unless genre == nil || album == nil
      album.genres << genre unless album.genres.include?(genre)
      album.save
    end
  end

  ##
  # Put l count of all items in the database
  def log_generated_count
    @log.info "Added or edited #{@count_labels} labels."
    @log.info "Added or edited #{@count_albums} albums."
    @log.info "Added or edited #{@count_releases} releases."
    @log.info "Added or edited #{@count_artists} artists."
    @log.info "Added or edited #{@count_genres} genres."
    @log.info "Added or edited #{@count_tracks} tracks."
    @log.info "Added or edited #{@count_videos} videos."
  end

  ##
  # Put l count of all items in the database
  def log_database_count
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
    Release.destroy_all
    Track.destroy_all

    @log.info "Database has been cleared."

    # Reset IDs
    if reset_id_nums
      ActiveRecord::Base.connection.execute("DELETE from sqlite_sequence where name = 'artists'")
      ActiveRecord::Base.connection.execute("DELETE from sqlite_sequence where name = 'labels'")
      ActiveRecord::Base.connection.execute("DELETE from sqlite_sequence where name = 'albums'")
      ActiveRecord::Base.connection.execute("DELETE from sqlite_sequence where name = 'genres'")
      ActiveRecord::Base.connection.execute("DELETE from sqlite_sequence where name = 'videos'")
      ActiveRecord::Base.connection.execute("DELETE from sqlite_sequence where name = 'tracks'")
      ActiveRecord::Base.connection.execute("DELETE from sqlite_sequence where name = 'releases'")
      @log.info "Table Primary Key IDs have been reset."
    end
  end

  ##
  # Make l request to the Discogs wrapper by passing the wrapper method (ie: get_label)
  # and the arguments (ie: id) for that method as params to this method. This method then calls the
  # provided wrapper method with it's argument(s) and makes the request and return the response.
  # If l rate limit error is returned, pause for 60 seconds and call the wrapper method again.
  # Note: Discogs rate limits to 60 requests per minute for authorized requests.
  def make_request(meth, *args)
    # response = callback.(id)
    response = meth.call(*args)

    # check if Discogs has rate limited the request
    if response.message == "You are making requests too quickly."
      @log.info "Rate Limit Exceeded: Discogs rate limits to 60 requests per minute."
      @log.info "Waiting 60 seconds and continuing..."
      sleep(60)
      # response = callback.(id)
      response = meth.call(*args)
    end

    response
  end
end