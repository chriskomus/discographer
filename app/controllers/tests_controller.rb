class TestsController < ApplicationController

  before_action do
    @discogs = Discogs::Wrapper.new(ENV['APP_NAME'], access_token: session[:access_token])
    @base_uri = 'https://api.discogs.com'
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

    request_data = @discogs.get_request_token('rZrsuCgpGSKSoEaeShFG', 'oTOgyQQCnwttQSoqqcvycWZJbCassNkv', 'http://127.0.0.1:3000/tests/callback')

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

  def show
    image = @discogs.get_image(params[:id])

    send_data(image,
              disposition: 'inline',
              type: 'image/jpeg')
  end

  def whoami
    @discogs = Discogs::Wrapper.new("AlbumCatalog", access_token: session[:access_token])

    @user = @discogs.get_identity
  end

  ##
  # Testing for basic discogs wrapper, authenticated so images will load
  def artist_albums
    wrapper = Discogs::Wrapper.new(ENV['APP_NAME'], access_token: session[:access_token])
    arr = [22673, 99459, 45, 269] # shpongle, carbon based lifeforms, aphex twin, squarepusher
    artist_id = arr[3]

    @artist = wrapper.get_artist(artist_id)
    @artist_image = @artist.images.find_all { |img| img.type == 'primary' }[0].uri

    total_count = wrapper.get_artist_releases(artist_id).pagination.items
    @artist_albums = wrapper.get_artist_releases(artist_id, :page => 1, :per_page => total_count).releases

    # @artist_albums = []
    # raw_artist_albums.each do |artist_album|
    #
    # end

    # @artist_albums = wrapper.get_artist_albums("329937")
    #  # @album = wrapper.get_release("161683")
    #     # @label = wrapper.get_label("3336")

  end

  ##
  # Basic testing discogs api without using the wrapper. Not authenticated so limited functionality.
  def artist
    req = 'artists'
    params = '22673'

    uri = URI("#{@base_uri}/#{req}/#{params}")

    # get response
    res = Net::HTTP.get_response(uri)

    # Body
    @object = ActiveSupport::JSON.decode res.body
    @artist_name = @object['name']
    @artist_profile = @object['profile']
    @artist_images = @object['images']
    @artist_image = @object['images'][0]['uri']
  end

end
