module Tagger
  class Test
    def self.id
      # cloud_file = Bucket.last.cloud_files.last
      # cloud_file.path_to_file = "/Users/jinx/Dropbox/eivu/sample/Sound Effects/Cow-SoundBible.com-868293659.mp3"
      # Tagger::Factory.generate(cloud_file).identify!

      # path = "/Users/jinx/Music/iTunes/iTunes\ Media/Music/Compilations/Essential\ Mix/11.08.2008\ \(256kbit\).m4a"
      # path = "/Users/jinx/Music/iTunes/iTunes\ Media/Music/White\ Label/Alicia/01\ Alicia.mp3"

      # cf = CloudFile.find(1978)
      # cf.path_to_file = "/Users/jinx/Desktop/sample/Justin\ Timberlake/Suit\ \&\ Tie\ \(Feat\ JAY\ Z\)\ -\ Single/01\ Suit\ \&\ Tie.mp3"
      # Tagger::Factory.generate("/Users/jinx/Dropbox/eivu/sample/Mala/Alicia/01\ Alicia.mp3").identify!
      # obj = cf
      # obj = "/Users/jinx/Desktop/sample/Justin\ Timberlake/Greatest\ Hits/05\ Rock\ Your\ Body.mp3"
      # obj = "/Users/jinx/Desktop/sample/Justin\ Timberlake/Greatest\ Hits/13\ \(Oh\ No\)\ What\ You\ Got.mp3"
      # obj = "/Users/jinx/Desktop/sample/Justin\ Timberlake/Greatest\ Hits/08\ Summer\ Love\ \(Set\ The\ Mood\).mp3"
      # obj = "/Users/jinx/Desktop/sample/Justin\ Timberlake/Greatest\ Hits/02\ What\ Goes\ Around,\ Comes\ Around.mp3"
      obj= "/Users/jinx/Dropbox/eivu/sample/Justin\ Timberlake/Justified/06\ Rock\ Your\ Body.mp3"
      t = Tagger::Factory.generate(obj)
      t.identify
    end


    def self.run
      # cloud_file = Bucket.last.cloud_files.last
      # cloud_file.path_to_file = "/Users/jinx/Dropbox/eivu/sample/Sound Effects/Cow-SoundBible.com-868293659.mp3"
      # Tagger::Factory.generate(cloud_file).identify!

      # path = "/Users/jinx/Music/iTunes/iTunes\ Media/Music/Compilations/Essential\ Mix/11.08.2008\ \(256kbit\).m4a"
      # path = "/Users/jinx/Music/iTunes/iTunes\ Media/Music/White\ Label/Alicia/01\ Alicia.mp3"
      
      cf = CloudFile.find(1978)
      cf.path_to_file = "/Users/jinx/Desktop/sample/Justin\ Timberlake/Suit\ \&\ Tie\ \(Feat\ JAY\ Z\)\ -\ Single/01\ Suit\ \&\ Tie.mp3"
      # Tagger::Factory.generate("/Users/jinx/Dropbox/eivu/sample/Mala/Alicia/01\ Alicia.mp3").identify!
      Tagger::Factory.generate(cf).identify_and_update!
    end


    def self.response

      title = "Suit & Tie (Feat JAY Z) - Single"
      response = {"status"=>"ok", "results"=>[{"recordings"=>[{"artists"=>[{"joinphrase"=>" feat. ", "id"=>"596ffa74-3d08-44ef-b113-765d43d12738", "name"=>"Justin Timberlake"}, {"id"=>"f82bcf78-5b69-4622-a5ef-73800768d9ac", "name"=>"Jay-Z"}], "duration"=>326, "releasegroups"=>[{"artists"=>[{"id"=>"596ffa74-3d08-44ef-b113-765d43d12738", "name"=>"Justin Timberlake"}], "type"=>"Album", "id"=>"deae6fc2-a675-4f35-9565-d2aaea4872c7", "title"=>"The 20/20 Experience"}, {"artists"=>[{"id"=>"596ffa74-3d08-44ef-b113-765d43d12738", "name"=>"Justin Timberlake"}], "secondarytypes"=>["Compilation"], "type"=>"Album", "id"=>"fe51b20f-83e4-49dd-9a36-b8d4da138325", "title"=>"The Complete 20/20 Experience"}, {"type"=>"Single", "id"=>"8f24e37b-5035-4383-89ff-818417f143e8", "title"=>"Suit & Tie"}], "title"=>"Suit & Tie", "id"=>"70003461-a6b3-4780-98e2-e1897cee0a7a"}], "score"=>0.968161, "id"=>"78dafd27-4c1f-4f99-9049-059bf39f666f"}, {"recordings"=>[{"artists"=>[{"joinphrase"=>" feat. ", "id"=>"596ffa74-3d08-44ef-b113-765d43d12738", "name"=>"Justin Timberlake"}, {"id"=>"f82bcf78-5b69-4622-a5ef-73800768d9ac", "name"=>"Jay-Z"}], "duration"=>326, "releasegroups"=>[{"artists"=>[{"id"=>"596ffa74-3d08-44ef-b113-765d43d12738", "name"=>"Justin Timberlake"}], "type"=>"Album", "id"=>"deae6fc2-a675-4f35-9565-d2aaea4872c7", "title"=>"The 20/20 Experience"}, {"artists"=>[{"id"=>"596ffa74-3d08-44ef-b113-765d43d12738", "name"=>"Justin Timberlake"}], "secondarytypes"=>["Compilation"], "type"=>"Album", "id"=>"fe51b20f-83e4-49dd-9a36-b8d4da138325", "title"=>"The Complete 20/20 Experience"}, {"type"=>"Single", "id"=>"8f24e37b-5035-4383-89ff-818417f143e8", "title"=>"Suit & Tie"}], "title"=>"Suit & Tie", "id"=>"70003461-a6b3-4780-98e2-e1897cee0a7a"}], "score"=>0.930842, "id"=>"6446d3af-61a5-48f9-beb2-4da2af9017f9"}]}
      response = Hashie::Mash.new(response)

      # list of albums under best recordings
      response.results[0].recordings[0].releasegroups
      # list of TITLES of best albums under recordings
      all_titles = response.results[0].recordings[0].releasegroups.collect(&:title)

      binding.pry


      response
    end
  end
end
