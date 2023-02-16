class Tagger::Audio < Tagger::Base
  def identify_and_update!(info=nil)
    identify(info)
    save_data!
  end


  # order of choice for release name after fuzzy matching fails
  # 1: id3 tag if _source is defined
  # 2: anything from API
  # 3: id3 tag
  # 4: empty hash
  def other_release_sources
    if @mp3_attr[:_source].present?
      { :title => @mp3_attr[:release] }
    elsif @fingerprint.response.present?
      @fingerprint.release.present?
    elsif @mp3_attr[:release].present?
      { :title => @mp3_attr[:release] } 
    else
      {}
    end      
  end


  def parse_metadata

    if @itunes_track_info.present?
      @mp3_attr[:_source]   = itunes_track_info.xxxxx
      @mp3_attr[:artists]   = Tagger::Audio.parse_artist_string(itunes_track_info.artist)
      @mp3_attr[:title]     = itunes_track_info.name
      @mp3_attr[:release]   = itunes_track_info.album
      @mp3_attr[:year]      = itunes_track_info.year
      @mp3_attr[:track_num] = itunes_track_info.track_number
      @mp3_attr[:genre]     = itunes_track_info.genre
      @mp3_attr[:num_plays] = itunes_track_info.play_count
    else
      ################
      #
      # Get Info via ID3
      mp3_info        = ID3Tag.read(@file)
      
      if mp3_info.artist.present?
        id3_artist = [{:name => mp3_info.artist, :primary => true}]
      else
        id3_artist = []
      end

      @mp3_attr[:_source]   = mp3_info.get_frames(:PRIV).try(:first).try(:owner_identifier) #"www.amazon.com" o "PeakValue"
      @mp3_attr[:artists]   = Tagger::Audio.parse_artist_string(mp3_info.artist) #id3_artist
      @mp3_attr[:title]     = mp3_info.title.try(:strip)
      @mp3_attr[:release]   = mp3_info.album.try(:strip)
      @mp3_attr[:year]      = mp3_info.year
      @mp3_attr[:track_num] = mp3_info.track_nr
      @mp3_attr[:genre]     = mp3_info.genre
      @mp3_attr[:comments]  = mp3_info.comments.try(:strip)
      @artwork_data         = mp3_info.get_frame(:APIC).try(:content)
    end
    @mp3_attr
  end



  def identify
    @mp3_attr       = Hashie::Mash.new
    @fp_attr = {}



    ################
    #
    # Get Info via AcouticFingerprint Service
    @fingerprint     = Fingerprinter.new(@mp3_attr[:title], @mp3_attr[:release], @path_to_file)
    @fingerprint.submit if @fingerprint.cleansed_fingerprint.present?

    @flags_via_path = Tagger::Audio.set_flags_via_path(@path_to_file)


    if @mp3_attr[:_source].present?
      track_name   = @mp3_attr[:title]
      release_name = @mp3_attr[:release]
    else
      track_name   = @fingerprint.track.try(:title) || @mp3_attr.title
    end

    track_id         = @fingerprint.track.try(:ext_id)
    release_id       = best_matching_release.try(:ext_id)
    release_name     = best_matching_release.try(:title) 
    @release_artists = @fingerprint.try(:release).try(:artists) || @mp3_attr[:artists]
    @track_artists   = @fingerprint.try(:track).try(:artists) || @mp3_attr[:artists]

    # creates hash to release metadata, nil values will be rmeoved.
    # is used by save_data fn
    # only created if we have valid release information
    if release_name || release_id
      @release_attrs = {
        :name => release_name,
        :ext_id => release_id,
        :data_source_id => 1
      }.merge(@flags_via_path).compact
    else
      @release_attrs = {}
    end

    # creates hash to store cloud file data, nil values will be rmeoved.
    # is used by save_data fn
    @cloud_file_attrs = {
      :name => track_name,
      :ext_id => track_id,
      :data_source_id => (track_id.present? ? 1 : nil),
      :release_pos => @mp3_attr[:track_num],
      :year => @mp3_attr[:year],
      :duration => @fingerprint.try(:duration)
    }.merge(@flags_via_path).compact

    # creates hash to store metadata, nil values will be rmeoved.
    # is used by save_data fn
    @metadata = Hashie::Mash.new({
      :genre => @mp3_attr[:genre],
      :comments => @mp3_attr[:comments],
      :acoustid_fingerprint => @fingerprint.try(:cleansed_fingerprint),
      :original_subpath => Folder.subpath(@path_to_file),
      :original_fullpath => @path_to_file,
    }).compact
  end
end