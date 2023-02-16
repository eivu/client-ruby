class Tagger::Video < Tagger::Base
  def determine_rating(path_to_file)
    if Pathname.new(path_to_file).basename.to_s.starts_with?("_")
      5
    elsif Pathname.new(path_to_file).basename.to_s.starts_with?("`")
      4.5
    end
  end
end