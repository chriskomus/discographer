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
  # Seed the database with all releases from an array of artists or an array of labels
  # @param artists - An array of Discogs Artist id #s
  # @param labels - An array of Discogs Label id #s
  # @param dump_data - If true the entire database will be cleared before seeding
  def seed_database(artists, labels)
    # iterate through each label
    labels.each_with_index do |id, i|
      # Create label in database
      new_label = create_or_get_label(id)

      @log.debug "[Processing Label] #{new_label.name}. Item #{i + 1} of #{labels.count}"

      generate_all_releases_on_label(id)
    end

    # iterate through each artist
    artists.each_with_index do |id, i|
      # Create label in database
      new_artist = create_or_get_artist(id)

      @log.debug "[Processing Artist] #{new_artist.name}. Item #{i + 1} of #{artists.count}"

      generate_all_releases_by_artist(id)
    end

    generated_count
  end

  ##
  # Generate all releases on a label from Discogs API
  def generate_all_releases_on_label(label_id)
    # Get label's releases
    page = 1
    per_page = 100
    req_method = @wrapper.method(:get_labels_releases)
    label_releases = make_request(req_method, label_id, { :page => page, :per_page => per_page })
    pages = label_releases.pagination.pages

    while page <= pages
      # Get next page of data, this has already been done for the first page, so if page is 1 this is skipped
      unless page == 1
        label_releases = make_request(req_method, label_id, { :page => page, :per_page => per_page })
      end

      # Iterate through a label's releases
      label_releases.releases.each_with_index do |r, i|
        @log.debug "[Processing Release] #{r.title}. Item #{i + 1} of #{label_releases.releases.count}"

        create_or_get_release(r.id)
      end

      page = page + 1
    end
  end

  ##
  # Generate all releases by an artist from Discogs API
  def generate_all_releases_by_artist(label_id)
    # Get artist's releases
    page = 1
    per_page = 100
    req_method = @wrapper.method(:get_artist_releases)
    artist_releases = make_request(req_method, artist_id, { :page => page, :per_page => per_page })
    pages = artist_releases.pagination.pages

    while page <= pages
      # Get next page of data, this has already been done for the first page, so if page is 1 this is skipped
      unless page == 1
        artist_releases = make_request(req_method, artist_id, { :page => page, :per_page => per_page })
      end

      # Iterate through an artist's releases
      artist_releases.releases.each_with_index do |r, i|
        @log.debug "[Processing Release] #{r.title}. Item #{i + 1} of #{artist_releases.releases.count}"

        create_or_get_release(r.id)
      end

      page = page + 1
    end
  end

  ##
  # Create or get a release from Discogs API
  # Take in a Discogs id and create a wrapper object,
  # then create an entry in the database
  # Add the release to the label, then add the artists and genre to the database
  def create_or_get_release(id)
    # Get release object
    # release = wrapper.get_release(id)
    # release = make_request(:wrapper.get_release(id))
    req_method = @wrapper.method(:get_release)
    release = make_request(req_method, id)

    unless release.title.blank?
      @log.info "[Adding Release] #{release.title}"

      # Create release in database
      new_release = Release.where(:catalog_num => release.catno).first_or_create { |item|
        item.title = release.title
        item.notes = release.notes
        item.year = release.year
        item.country = release.country
        item.discogs_id = release.id
      }

      # Get release's labels and iterate through them, adding to database
      release_labels = release.labels
      release_labels.each_with_index do |rl, i|
        @log.debug "[Processing Label] #{rl.name}. Item #{i + 1} of #{release_labels.count}"
        new_label = create_or_get_label(rl.id)

        # Associate release with label
        add_release_to_label(new_release, new_label)

        # Get release's artists and iterate through them, adding to database
        release_artists = release.artists
        release_artists.each_with_index do |ra, j|
          @log.debug "[Processing Artist] #{ra.name}. Item #{j + 1} of #{release_artists.count}"
          new_artist = create_or_get_artist(ra.id)

          # Associate artist with release
          add_artist_to_release(new_artist, new_release)

          # Associate artist with label
          add_artist_to_label(new_artist, new_label)
        end
      end

      # Get release's genres and iterate through them, adding to database
      release_genres = release.styles
      release_genres.each_with_index do |rg, k|
        @log.debug "[Processing Genre] #{rg}. Item #{k + 1} of #{release_genres.count}"
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
  def create_or_get_label(id)
    # Get label object
    # label = wrapper.get_label(id)
    # req_method = wrapper.method(:get_label)
    # label = make_request(req_method, id)
    req_method = @wrapper.method(:get_label)
    label = make_request(req_method, id)

    unless label.name.blank?
      @log.info "[Adding Label] #{label.name}"

      # Create label in database
      Label.where(:discogs_id => id).first_or_create { |item|
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
  # Then add the artist to the release, and the artist to the label.
  def create_or_get_artist(id)
    # Get artist object
    # artist = wrapper.get_artist(id)
    # artist = make_request(:wrapper.get_artist(id))
    req_method = @wrapper.method(:get_artist)
    artist = make_request(req_method, id)

    unless artist.name.blank?
      @log.info "[Adding Artist] #{artist.name}"

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
    @log.info "Database contains #{Label.count} labels."
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
    Release.destroy_all
    Genre.destroy_all
    # Track.destroy_all
    # Video.destroy_all
    #
    @log.warn "Database has been cleared."

    # Reset IDs
    if reset_id_nums
      ActiveRecord::Base.connection.execute("DELETE from sqlite_sequence where name = 'artists'")
      ActiveRecord::Base.connection.execute("DELETE from sqlite_sequence where name = 'labels'")
      ActiveRecord::Base.connection.execute("DELETE from sqlite_sequence where name = 'releases'")
      ActiveRecord::Base.connection.execute("DELETE from sqlite_sequence where name = 'genres'")
      # ActiveRecord::Base.connection.execute("DELETE from sqlite_sequence where name = 'tracks'")
      # ActiveRecord::Base.connection.execute("DELETE from sqlite_sequence where name = 'videos'")
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

import_discogs.clear_database(true)
import_discogs.seed_database(artists, labels)