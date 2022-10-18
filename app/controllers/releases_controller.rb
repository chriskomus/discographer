class ReleasesController < ApplicationController
  before_action :set_release, only: %i[ show edit update destroy ]

  # GET /releases or /releases.json
  def index
    @album = nil
    if params[:album_id].present?
      @album = Album.find_by_id(params[:album_id])
      if @album.present?
        @header = "Releases: #{@album.title}"
        @releases = Release.where(album: @album)
      end
    else
      @header = 'Releases'
      @releases = Release.all
    end
  end

  # GET /releases/1 or /releases/1.json
  def show
  end

  # GET /releases/new
  def new
    @release = Release.new
    @header = 'New Release'
    if params[:album_id].present?
      @album = Album.find_by_id(params[:album_id])
      if @album.present?
        @header = "Add Release: #{@album.title}"
      end
    end
  end

  # GET /releases/1/edit
  def edit
  end

  # POST /releases or /releases.json
  def create
    @release = Release.new(release_params)

    respond_to do |format|
      if @release.save
        format.html { redirect_to release_url(@release), notice: "Release was successfully created." }
        format.json { render :show, status: :created, location: @release }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @release.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /releases/1 or /releases/1.json
  def update
    respond_to do |format|
      if @release.update(release_params)
        format.html { redirect_to release_url(@release), notice: "Release was successfully updated." }
        format.json { render :show, status: :ok, location: @release }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @release.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /releases/1 or /releases/1.json
  def destroy
    @release.destroy

    respond_to do |format|
      format.html { redirect_to releases_url, notice: "Release was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_release
      @release = Release.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def release_params
      params.require(:release).permit(:id, :catno, :album_id, :label_id)
    end
end
