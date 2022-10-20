class AlbumsController < ApplicationController
  before_action :set_album, only: %i[ show edit update destroy ]

  # GET /Albums or /Albums.json
  def index
    # @albums = Album.all
    @albums = Album.search(params[:search]).sort_by &:title
  end

  # GET /Albums/1 or /Albums/1.json
  def show

    # Album artists as string
    @album_artists = ''
    @album.artists.each_with_index do |artist, i|
      @album_artists += artist.name
      @album_artists += i + 1 < @album.artists.count ? ', ' : ''
    end

    if @album.genres.present?
      @album_genres = @album.genres.sort_by &:name
    else
      @album_genres = []
    end

    if @album.tracks.present?
      @album_tracks = @album.tracks.sort_by &:position
    else
      @album_tracks = []
    end
  end

  # GET /Albums/new
  def new
    @album = Album.new
  end

  # GET /Albums/1/edit
  def edit

  end

  # POST /Albums or /Albums.json
  def create
    @album = Album.new(album_params)

    respond_to do |format|
      if @album.save
        format.html { redirect_to album_url(@album), notice: "Album was successfully created." }
        format.json { render :show, status: :created, location: @album }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @album.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /Albums/1 or /Albums/1.json
  def update

    respond_to do |format|
      if @album.update(album_params)
        format.html { redirect_to album_url(@album), notice: "Album was successfully updated." }
        format.json { render :show, status: :ok, location: @album }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @album.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /Albums/1 or /Albums/1.json
  def destroy
    @album.destroy

    respond_to do |format|
      format.html { redirect_to albums_url, notice: "Album was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_album
    @album = Album.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def album_params
    params.require(:album).permit(:id, :year, :title, :country, :notes, :imageuri, :discogs_id, :search, :artist_ids => [], :genre_ids => [])
  end

end
