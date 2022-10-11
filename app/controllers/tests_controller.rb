class TestsController < ApplicationController

  before_action do
    @discogs = Discogs::Wrapper.new('AlbumCatalog', access_token: session[:access_token])

    @base_uri = 'https://api.discogs.com'
    # @request_token = ''
  end

  def index
  end

  def authenticate
    # @discogs = Discogs::Wrapper.new('AlbumCatalog', access_token: session[:access_token])
    # session[:request_token] = nil

    callback = "http://127.0.0.1:3000/tests/callback"
    # app_key = ENV['DISCOGS_API_KEY']
    # app_secret = ENV['DISCOGS_API_SECRET']
    # oauth_token = ENV['DISCOGS_API_OAUTH_TOKEN']
    # oauth_token_secret = ENV['DISCOGS_API_OAUTH_TOKEN_SECRET']
    # oauth_verifier = ENV['DISCOGS_API_OAUTH_VERIFIER']

    # request_data = @discogs.get_request_token(app_key, app_secret,
    #                                           callback_url)

    consumer = OAuth::Consumer.new(ENV['DISCOGS_API_KEY'], ENV['DISCOGS_API_SECRET'],
                                   :authorize_url => "https://www.discogs.com/oauth/authorize",
                                   :site          => "https://api.discogs.com")
    @request_token = consumer.get_request_token(:oauth_callback => callback)
    authorize_url = @request_token.authorize_url(:oauth_callback => callback)

    logger.info @request_token

    # session[:request_token] = @request_token.to_yaml
    session[:request_token] = @request_token

    redirect_to authorize_url, allow_other_host: true
    # redirect_to callback, allow_other_host: true
    # redirect_to :action => 'index'
  end

  def callback
    # @discogs = Discogs::Wrapper.new('AlbumCatalog', access_token: session[:access_token])
    # request_token = YAML.load(session[:request_token])

    # oauth_verifier = ENV['DISCOGS_API_OAUTH_VERIFIER']
    # logger.info request_token
    # logger.info verifier

    # Re-create the request token
    # consumer = OAuth::Consumer.new(ENV['DISCOGS_API_KEY'], ENV['DISCOGS_API_SECRET'],
    #                                :authorize_url => "https://www.discogs.com/oauth/authorize",
    #                                :site          => "https://api.discogs.com")
    # request_token = consumer.get_request_token(:oauth_callback => callback)

    # access_token = @request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])

    # session[:access_token] = access_token

    request_token = session[:request_token]
    verifier = params[:oauth_verifier]

    if request_token.is_a?(OAuth::RequestToken)
      access_token = request_token.get_access_token(:oauth_verifier => verifier)

      session[:request_token] = nil
      session[:access_token] = access_token

      @discogs.access_token = access_token

      logger.info access_token

    else
      logger.warn 'request_token invalid'
    end

    redirect_to action: 'index'

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

    # @artist = wrapper.get_artist("329937")
    # @artist_releases = wrapper.get_artist_releases("329937")
    # @release = wrapper.get_release("1529724")
    # @label = wrapper.get_label("29515")
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
    callback_url = "http://127.0.0.1:3000/oauth/callback"
    app_key = ENV['DISCOGS_API_KEY']
    app_secret = ENV['DISCOGS_API_SECRET']
    oauth_token = ENV['DISCOGS_API_OAUTH_TOKEN']
    oauth_token_secret = ENV['DISCOGS_API_OAUTH_TOKEN_SECRET']
    oauth_verifier = ENV['DISCOGS_API_OAUTH_VERIFIER']

    category = 'artists'
    params = '22673'

    uri = URI("#{@base_uri}/#{category}/#{params}")
    #
    # req = Net::HTTP::Get.new(uri.request_uri)
    #
    # req['Content-Type'] = "application/x-www-form-urlencoded"
    # req['Authorization'] = "OAuth oauth_consumer_key=\"#{app_key}\", oauth_nonce=\"#{DateTime.now}\", oauth_token=\"#{oauth_token}\", oauth_signature=\"#{app_secret}\", oauth_signature_method=\"PLAINTEXT\", oauth_timestamp=\"#{DateTime.now}\", oauth_verifier=\"#{oauth_verifier}\""
    #
    # res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') { |http|
    #   http.request(req)
    # }
    #
    # open 'cached_response', 'w' do |io|
    #   io.write res.body
    # end if res.is_a?(Net::HTTPSuccess)

    # hydra = Typhoeus::Hydra.new
    # request = Typhoeus::Request.new(
    #   uri,
    #   method: :get,
    #   headers: { Accept: "text/html" }
    # )
    # request.on_complete do |response|
    #   @object = Yajl::Parser.parse(response.body) #or Yajl::Parser.parse(response.body)
    #   @artist_name = @object['name']
    #   @artist_profile = @object['profile']
    #   @artist_image = @object['images'][0]['uri']
    # end
    #
    # hydra.queue(request)
    # hydra.run

    # oauth_consumer = OAuth::Consumer.new(app_key, app_secret, site: uri)
    #
    # hash = { oauth_token: oauth_token, oauth_token_secret: oauth_token_secret }
    # request_token = OAuth::RequestToken.from_hash(oauth_consumer, hash)
    # access_token = request_token.get_access_token(oauth_verifier: oauth_verifier)
    #
    # oauth_params = { consumer: oauth_consumer, token: access_token }
    # hydra = Typhoeus::Hydra.new
    # req = Typhoeus::Request.new(uri, options) # :method needs to be specified in options
    # oauth_helper = OAuth::Client::Helper.new(req, oauth_params.merge(request_uri: uri))
    # req.options[:headers]["Authorization"] = oauth_helper.header # Signs the request
    # hydra.queue(req)
    # hydra.run
    # @response = req.response

    # #
    # # # get response
    # res = Net::HTTP.get_response(uri)
    #
    # # Body
    # @object = ActiveSupport::JSON.decode res.body
    # @artist_name = @object['name']
    # @artist_profile = @object['profile']
    # @artist_image = @object['images'][0]['uri']
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
    @artist_image = @object['images'][0]['uri']
  end

end
