class TestsController < ApplicationController

  before_action do
    @discogs = Discogs::Wrapper.new('AlbumCatalog', access_token: session[:access_token])

    @base_uri = 'https://api.discogs.com'
  end

  def index
  end

  def authenticate
    app_key = ENV["DISCOGS_API_KEY"]
    app_secret = ENV["DISCOGS_API_SECRET"]
    callback = "http://127.0.0.1:3000/tests/callback"

    request_data = @discogs.get_request_token(app_key, app_secret, callback)

    session[:request_token] = request_data[:request_token]

    redirect_to request_data[:authorize_url], allow_other_host: true
  end

  def callback
    request_token = session[:request_token]
    verifier = params[:oauth_verifier]
    access_token = @discogs.authenticate(request_token, verifier)

    session[:request_token] = nil
    session[:access_token] = access_token

    redirect_to action: "index"
  end

  # Once you have it, you can also pass your access_token into the constructor.
  def another_action
    @discogs = Discogs::Wrapper.new("AlbumCatalog", access_token: session[:access_token])

    # You can now perform authenticated requests.
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

  # testing for basic discogs wrapper
  def add_want
    wrapper = Discogs::Wrapper.new('AlbumCatalog', access_token: session[:access_token])
    arr = [22673, 99459, 45, 269] # shpongle, carbon based lifeforms, aphex twin, squarepusher
    artist_id = arr[3]

    @artist = wrapper.get_artist(artist_id)
    @artist_image = @artist.images.find_all { |img| img.type == 'primary' }[0].uri

    total_count = wrapper.get_artist_releases(artist_id).pagination.items
    raw_artist_releases = wrapper.get_artist_releases(artist_id, :page => 1, :per_page => total_count).releases

    @artist_releases = []
    raw_artist_releases.each do |artist_release|

    end

    # @artist_releases = wrapper.get_artist_releases("329937")
    #  # @release = wrapper.get_release("161683")
    #     # @label = wrapper.get_label("3336")

  end

  def edit_want
    # release_id = '2489281'
    # notes = 'Added via the Discogs Ruby Gem. But, you *DO* want it now!!'
    # rating = 5
    #
    # @user = @discogs.get_identity
    # @response = @discogs.edit_release_in_user_wantlist(@user.username,
    #                                                    release_id,
    #                                                    { :notes => notes, :rating => rating })
  end

  def remove_want
  end

  # testing discogs api without wrapper
  def get_artist
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
