# == Schema Information
#
# Table name: folders
#
#  id                :integer          not null, primary key
#  name              :string
#  created_at        :datetime
#  updated_at        :datetime
#  ancestry          :string
#  bucket_id         :integer
#  peepy             :boolean          default(FALSE), not null
#  nsfw              :boolean          default(FALSE), not null
#  cloud_files_count :integer          default(0), not null
#  subfolders_count  :integer          default(0), not null
#
# Description: Folders are only metadata to preserve the same tree layout as found on the user's drive
class Folder < ApplicationRecord
  include Reactable
  has_ancestry

  belongs_to :bucket
  has_many :cloud_files, -> { order('release_pos' )}

  validates_uniqueness_of :name, scope: :ancestry

  # scope :clean, where(:peepy => false)
  scope(:alpha, -> { order('name') })
  scope(:clean, -> { where(peepy: false) })
  scope(:peepy, -> { where(peepy: true) })

  scope(:has_files, -> { where('cloud_files_count > 0') })
  scope(:has_subfolders, -> { where('subfolders_count > 0') })
  scope(:has_content, -> { where('subfolders_count > 0 OR cloud_files_count > 0') })
  # default_scope { where(:peepy => false) }

  #for current version of app, everything is being saved to same bucket, as development proceeds this must be altered
  @@bucket = nil
  #The root folder containing all content will be same ie ~/Music. we want to remove ~/Music from all directory paths, as we try to replicate the path on s3
  @@ignore = nil
  #making it a set so duplicates won't be stored
  @@errors = Set.new

  SKIPABLE_FILETYPES = %w(m4p nfo sfv)


  class << self
    def create_from_path(path_to_file)
      #save file in "root" of folder if ignore is blank
      return nil if @@ignore.blank?
      @folder = @parent = nil
      # bucket = @@bucket || Bucket.ensure(bucket)
      path_name = Pathname.new(path_to_file.gsub(@@ignore,""))   
      path_name.dirname.to_s.split("/").each do |folder_name|
        @folder   = Folder.find_or_create_by!(:name => folder_name.to_s, :ancestry => @parent.try(:path_ids).try(:join, "/"))
        @parent   = @folder
      end
      @folder
    end

    def subpath(path_to_item)
      path_to_item.gsub(@@ignore.to_s,"")
    end

    def upload(path_to_dir, bucket, options={})
      bucket = @@bucket || Bucket.ensure(bucket)
      Folder.traverse(path_to_dir) do |path_to_item|
        puts "=== UPLOADING #{path_to_item.gsub(@@ignore,"")}"
        CloudFileIngesterJob.perform_later(path_to_item, bucket, options)
      end
    end


    def upload!(path_to_dir, bucket, options={})
      Folder.upload(path_to_dir, bucket, options.merge(:prune => true))
    end


    def clean!(path_to_dir, bucket)
      bucket = Bucket.ensure(bucket)
      Folder.traverse(path_to_dir) do |path_to_item|
        md5  = Digest::MD5.file(path_to_item).hexdigest.upcase
        cloud_file = CloudFile.where(:md5 => md5, :bucket_id => bucket.id).first
        if cloud_file.present? && CloudFile.online?(cloud_file.url)
          puts "=== DELETING #{path_to_item.gsub(@@ignore,"")}"
          FileUtils.rm(path_to_item) 
        else
          puts ... SKIPPING #{path_to_item.gsub(@@ignore,"")}"
        end
      end
    end


    # #updates the folders that videos are in
    # def update_tree(path_to_dir)
    #   Folder.traverse(path_to_dir) do |path_to_item|
    #     puts "=== UPDATING #{path_to_item.gsub(@@ignore,"")}"
    #     folder = Folder.create_from_path(path_to_item)
    #     CloudFile.find_by_md5(Digest::MD5.file(path_to_item).hexdigest.upcase).update_attributes! :folder_id => folder.id
    #   end
    # end


    #traverse the tree and upload every file
    def traverse(path_to_dir)
      @@ignore = path_to_dir.strip
      @@ignore += "/" unless @@ignore.ends_with?("/")
      #grab all folders in the dir
      Dir.glob("#{path_to_dir}/**/*").each do |path_to_item|
        next if path_to_item.starts_with?(".") || SKIPABLE_FILETYPES.any? {|ext| path_to_item.ends_with?(ext) } || File.directory?(path_to_item)
        begin
          yield path_to_item
        # should rescue RuntimeError => e
        rescue Exception => error
          unless error.message == "Validation failed: Md5 has already been taken" || error.message.starts_with?("File already exists")
            puts "  skipping (#{error})"
            puts "  from"
            puts error.backtrace.join("\n")
            @@errors << { error.message => path_to_item }
          end
        end
      end
      nil
    end

    def errors
      @@errors
    end
  end
end
