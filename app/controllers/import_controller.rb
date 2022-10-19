class ImportController < ApplicationController
  before_action do
    @discogs = Discogs::Wrapper.new(ENV['APP_NAME'], access_token: session[:access_token])
  end

  def index
  end

  ##
  # Authenticate discog's api using app key and secret, then save a request token as a session var
  # Redirect to discogs to authenticate and then get passed to the callback function with the oath verifier
  def authenticate
    app_key = ENV["DISCOGS_API_KEY"]
    app_secret = ENV["DISCOGS_API_SECRET"]
    callback = ENV["CALLBACK_URI"]

    request_data = @discogs.get_request_token(app_key, app_secret, callback)

    session[:request_token] = request_data[:request_token]

    redirect_to request_data[:authorize_url], allow_other_host: true
  end

  ##
  # After an oauth request has been made to discogs, user is passed to callback function
  # where an access_token is created and stores as a session var. Redirected to index afterwards and user should now
  # be authenticated.
  # Authentication is only needed when requestion image uris.
  def callback
    request_token = session[:request_token]
    verifier = params[:oauth_verifier]
    access_token = @discogs.authenticate(request_token, verifier)

    session[:request_token] = nil
    session[:access_token] = access_token

    redirect_to action: "index"
  end

  ##
  # Testing for basic discogs wrapper, authenticated so images will load
  def test_connection
    artist_id = 27862 # discogs id

    begin
      @artist = @discogs.get_artist(artist_id)

      if @artist.present?
        @artist_image = @artist.images.find_all { |img| img.type == 'primary' }[0].uri
      end
    rescue
      @artist = nil
    end
  end

  ##
  # Display the logged in username
  def user_info
    if @discogs.authenticated?
      @user = @discogs.get_identity
    else
      @user = nil
    end
  end

  def import_album_info
    @album = nil
    if params[:album_id].present?
      @album = Album.find_by_id(params[:album_id])
      if @album.present? && @album.discogs_id.present?
        @discogs_id = @album.discogs_id

        discogs_service = DiscogsService.new(@discogs)
        @album = discogs_service.create_or_get_album(@discogs_id)
      end
    end

    respond_to do |format|
      if @album.present?
        format.html { redirect_to album_url(@album), notice: "Album was successfully imported." }
        format.json { render :show, status: :ok, location: @album }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { head :no_content }
      end
    end
  end

  def import_album_imageuri
    @album = nil
    if params[:album_id].present?
      @album = Album.find_by_id(params[:album_id])
      if @album.present? && @album.discogs_id.present?
        @discogs_id = @album.discogs_id

        discogs_service = DiscogsService.new(@discogs)
        @album = discogs_service.create_or_get_album(@discogs_id)
      end
    end
  end

  def import_artist_info
    @album = nil
    if params[:artist_id].present?
      @album = Artist.find_by_id(params[:artist_id])
      if @artist.present? && @artist.discogs_id.present?
        @discogs_id = @artist.discogs_id
      end
    end
  end

  def import_artist_imageuri
    @artist = nil
    if params[:artist_id].present?
      @artist = Artist.find_by_id(params[:artist_id])
      if @artist.present? && @artist.discogs_id.present?
        @discogs_id = @artist.discogs_id
      end
    end
  end

  def import_all_imageuris

  end

  def import_all_albums_from_artist
    @artist = nil
    if params[:artist_id].present?
      @artist = Artist.find_by_id(params[:artist_id])
      if @artist.present? && @artist.discogs_id.present?
        @discogs_id = @artist.discogs_id
      end
    end
  end

  def import_all_albums_from_label
    @label = nil
    if params[:label_id].present?
      @label = Artist.find_by_id(params[:label_id])
      if @label.present? && @label.discogs_id.present?
        @discogs_id = @label.discogs_id
      end
    end
  end

end
