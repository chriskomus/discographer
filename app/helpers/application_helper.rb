module ApplicationHelper

  def is_active(action)
    current_page?(:controller => action) ? 'active' : ''
  end

  ##
  # Album artists as string
  def artists_as_string(album)
    @album_artists = ''
    album.artists.each_with_index do |artist, i|
      @album_artists += artist.name
      @album_artists += i + 1 < album.artists.count ? ', ' : ''
    end

    @album_artists
  end
end
