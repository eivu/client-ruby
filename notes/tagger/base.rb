class Tagger::Base

  class << self
    def set_flags_via_path(path_to_file)
      if path_to_file.present? && (path_to_file.include?("/pronz") || path_to_file.include?("/peepshow"))
        {
          :peepy => true,
          :nsfw => true
        }
      else
        {}
      end
    end

    def parse_artist_string(value)
      return [] if value.blank?
      value.split("&").collect do |name|
        {:name => name.strip, :primary => true }
      end
    end
  
    def convert_primary_to_value(input)
      if input
        1
      else
        2
      end
    end
  end



  def initialize(input, mime, file, options={})
    if input.is_a? String
      @path_to_file = input
    elsif input.is_a? CloudFile
      @cloud_file   = input
      @path_to_file = input.path_to_file
    end

    @mime       = mime
    @file       = file
    @options    = options
    @itunes_track_info = @options[:itunes_track_info]
    @attributes = {}
  end


  def save_data!
    return if @cloud_file.blank?

    if @release_attrs.compact.present?
      @release = Release.configure_and_save!(@release_attrs)
      @release_artists.each do |raw_artist|
        artist = Artist.configure_and_save! :name => raw_artist.name, :ext_id => raw_artist.ext_id, :data_source_id => @release.data_source_id
        ArtistRelease.find_or_create_by! :artist_id => artist.id, :release_id => @release.id, :relationship_id => Tagger::Base.convert_primary_to_value(raw_artist.primary)
      end

      @track_artists.each do |raw_artist|
        artist = Artist.configure_and_save! :name => raw_artist.name, :ext_id => raw_artist.ext_id, :data_source_id => @release.data_source_id
        ArtistCloudFile.find_or_create_by! :artist_id => artist.id, :cloud_file_id => @cloud_file.id, :relationship_id => Tagger::Base.convert_primary_to_value(raw_artist.primary)
      end

      @cloud_file.update_attributes(@cloud_file_attrs.merge(:release_id => @release.id))
    end
    
    @metadata.each do |key, value|
      label   = key.to_s.gsub("_", " ").titlecase
      type    = MetadataType.find_or_create_by!(:value => label)
      datum   = Metadatum.find_or_create_by!(:value => value, :user_id => @cloud_file.user_id, :metadata_type_id => type.id)
      Metatagging.find_or_create_by!(:metadatum_id => datum.id, :cloud_file_id => @cloud_file.id)
    end

    # Uploads release artwork
    if @artwork_data.present?
      temp_artwork = Tempfile.new(SecureRandom.uuid)
      temp_artwork.binmode
      temp_artwork.write(@artwork_data)
      CloudFileUploaderService.upload(temp_artwork.path, @cloud_file.bucket, :folder_id => @cloud_file.folder_id, :release_id => @cloud_file.release_id)
    end
  end
end