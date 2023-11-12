class Tagger::Factory
  def self.generate(input, options={})
    if input.is_a? String
      path_to_file = input
    elsif input.is_a? CloudFile
      cloud_file = input
      path_to_file = input.path_to_file
    end

    extension = File.extname(path_to_file)
    file      = File.open(path_to_file)
    
    if extension.present?
      mime    = MimeMagic.by_extension(".m4a")
    else
      mime    = MimeMagic.by_magic(file)
    end

    klass     = Kernel.const_get("Tagger::#{mime.mediatype.titlecase}")
    klass.new(input, mime, file, options)
  end
end