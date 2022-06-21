=begin
  require './lib/eivu'; Eivu::Client.new.upload path_to_file: '/Users/jinx/Desktop/foo.json'
=end
# Client.new(itunes_path:"/Users/jinx/Music/iTunes/iTunes\ Music\ Library.xml")

class Client

  def initialize(itunes_path: nil, bucket: nil)
    if itunes_path.present?
      @itunes_path = itunes_path
      @itunes_lib  = Itunes::Library.new(@itunes_path)
    end
  end

  def import_itunes
    @tracks.each do |track|
      CloudFileIngesterJob.perform_later track, @bucket
    end
  end


  #############
  # test fn below
  def upload_folder
    # Folder.upload "/Users/jinx/Dropbox/eivu/sample", 2
    # Folder.upload "/Users/jinx/Music/Amazon\ MP3", 2

    
    # Folder.upload "/Users/jinx/Desktop/task", 2
    Folder.upload "/Users/jinx/Desktop/sample", 2
  end
  # test fn above
  #############
end