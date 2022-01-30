# frozen_string_literal: true

FactoryBot.define do
  factory :cloud_file do
    trait :peepy do
      peepy { true }
    end

    trait :nsfw do
      nsfw { true }
    end

    # trait :broken_piano do
    #   name { 'Piano_brokencrash-Brandondorf-1164520478.mp3' }
    #   asset { 'Piano_brokencrash-Brandondorf-1164520478.mp3' }
    #   md5 { 'A4FFA621BC8334B4C7F058161BDBABBF' }, "content_type"=>"audio/mpeg", "filesize"=>134899, "description"=>nil, "rating"=>nil, "nsfw"=>false, "peepy"=>false, "created_at"=>Thu, 14 May 2015 05:40:25.870345000 UTC +00:00, "updated_at"=>Thu, 14 May 2015 05:40:25.870345000 UTC +00:00, "folder_id"=>nil, "info_url"=>nil, "bucket_id"=>2, "duration"=>0, "settings"=>0, "ext_id"=>nil, "data_source_id"=>nil, "release_id"=>nil, "year"=>nil, "release_pos"=>nil, "user_id"=>nil, "num_plays"=>0, "state"=>"empty"}

    # end

    trait :reserved do
      md5 { Faker::Crypto.md5 }
      bucket_id { rand(1..10) }
      state { 'reserved' }
    end

    trait :transfered do
      reserved
      content_type { Faker::File.mime_type }
      asset { "#{Faker::Lorem.word.downcase}.#{Faker::File.extension}" }
      filesize { rand(100.kilobytes..2.gigabytes) }
      state { 'transfered' }
    end

    trait :completed do
      transfered
      state { 'completed' }
    end

    trait :audio do
      content_type { 'audio/mpeg' }
      filesize { rand(750.kilobytes..10.megabytes) }
      asset { "#{Faker::Lorem.word.downcase}.mp3" }
    end
  end
end
