class VideosController < ApplicationController
  before_action :set_video, only: %i[ show edit update destroy ]

  # GET /videos or /videos.json
  def index
    @album = nil
    if params[:album_id].present?
      @album = Album.find_by_id(params[:album_id])
      if @album.present?
        @header = "Videos: #{@album.title}"
        @videos = Video.where(album: @album).sort_by &:title
      end
    else
      @header = 'Select an album to see videos'
      @albums = Album.all.sort_by &:title
    end
  end

  # GET /videos/1 or /videos/1.json
  def show
    # Convert YouTube links to embedded links
    @embed_link = @video.uri.gsub! 'www.youtube.com/watch', 'www.youtube.com/embed'
  end

  # GET /videos/new
  def new
    @video = Video.new
    @header = 'New Video'
    if params[:album_id].present?
      @album = Album.find_by_id(params[:album_id])
      if @album.present?
        @header = "Add Video to: #{@album.title}"
      end
    end
  end

  # GET /videos/1/edit
  def edit
  end

  # POST /videos or /videos.json
  def create
    @video = Video.new(video_params)

    respond_to do |format|
      if @video.save
        format.html { redirect_to video_url(@video), notice: "Video was successfully created." }
        format.json { render :show, status: :created, location: @video }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /videos/1 or /videos/1.json
  def update
    respond_to do |format|
      if @video.update(video_params)
        format.html { redirect_to video_url(@video), notice: "Video was successfully updated." }
        format.json { render :show, status: :ok, location: @video }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /videos/1 or /videos/1.json
  def destroy
    @video.destroy

    respond_to do |format|
      format.html { redirect_to videos_url, notice: "Video was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_video
      @video = Video.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def video_params
      params.require(:video).permit(:id, :title, :uri, :description, :album_id)
    end
end
