# frozen_string_literal: true

FactoryBot.define do
  factory :cloud_file, class: Eivu::Client::CloudFile do
    initialize_with { new(attributes) }

    md5 { Faker::Crypto.md5 }
    bucket_uuid { SecureRandom.uuid }
    bucket_name { Faker::Name.name.downcase }
    state { 'reserved' }
    created_at { Time.now.to_s }
    updated_at { Time.now.to_s }
    content_type { Faker::File.mime_type }
    asset { "#{Faker::Lorem.word.downcase}.#{Faker::File.extension}" }
    filesize { rand((100.kilobytes)..(2.gigabytes)) }
    state_history { [:reserved] }

    trait :delicate do
      peepy { true }
    end

    trait :peepy do
      peepy { true }
    end

    trait :nsfw do
      nsfw { true }
    end

    trait :transfered do
      state { 'transfered' }
      state_history { %i[reserved transfered] }
    end

    trait :completed do
      state { 'completed' }
      state_history { %i[reserved transfered completed] }
    end

    trait :audio do
      content_type { 'audio/mpeg' }
      filesize { rand((750.kilobytes)..(10.megabytes)) }
      asset { "#{Faker::Lorem.word.downcase}.mp3" }
    end

    trait :video do
      content_type { 'video/mpeg' }
      filesize { rand((750.kilobytes)..(10.megabytes)) }
      asset { "#{Faker::Lorem.word.downcase}.mp4" }
    end

    trait :image do
      content_type { 'image/png' }
      filesize { rand((750.kilobytes)..(10.megabytes)) }
      asset { "#{Faker::Lorem.word.downcase}.png" }
    end

    trait :other do
      content_type { 'application/pdf' }
      filesize { rand((750.kilobytes)..(10.megabytes)) }
      asset { "#{Faker::Lorem.word.downcase}.pdf" }
    end

    trait :test_mp3 do
      md5 { 'F45C04D717F3ED6720AE0A3A67981FE4' }
      asset { 'test.mp3' }
      content_type { 'audio/mpeg' }
      filesize { 4365 }
    end
  end
end
