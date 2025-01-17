require "#{Rails.root}/spec/support/consts"

FactoryGirl.define do
  # A factory that produces images which just go through validations.
  factory :image_min, class: Image do
    sequence(:src_url) { |n| "http://lohas.nicoseiga.jp/thumb/3804029i#{n}" }
  end

  factory :image_today, class: Image do
    sequence(:src_url) { |n| "http://lohas.nicoseiga.jp/thumb/3804029i#{n}" }
    created_at DateTime.now.utc
  end

  # The main factory. This generates Image objects with various attributes.
  factory :image, class: Image do
    title 'test'
    caption 'test'
    sequence(:src_url) { |n| "test#{n}@example.com" }
    sequence(:created_at) { |n| Time.mktime(2014, 1, n, 0, 0, 0) }  # Is saved in UTC format
    sequence(:page_url) { |n| "test#{n}@example.com/some_page" }
    sequence(:site_name) { |n| Constants::SITE_NAMES[n % Constants::SITE_NAMES.count] }
    sequence(:module_name) { |n| Constants::MODULE_NAMES[n % Constants::MODULE_NAMES.count] }
    original_view_count 10000
    posted_at DateTime.now
    is_illust true


    # Creates an image that has specific, not sequenced tags
    factory :image_with_specific_tags do
      after(:create) do |image|
        image.tags << create(:tag)
        image.tags << create(:tag_en)
        image.tags << create(:tag_title)
      end
    end

    # Creates an image that has sequenced tags
    factory :image_with_tags do
      transient do
        tags_count 5
      end
      after(:create) do |image, evaluator|
        (0..evaluator.tags_count-1).each do
          image.tags << create(:tag)
        end
      end
    end

    # Skip validation when saving
    to_create do |instance|
      instance.save validate: false
    end
  end


  # Creates an image that has different posted_at time from :image factory
  factory :image_dif_time, class: Image do
    title 'test'
    caption 'test'
    sequence(:src_url) { |n| "test#{n}@example.com" }
    sequence(:created_at) { |n| Time.mktime(2014, 1, n, 0, 0, 0) }  # Saved in UTC
    sequence(:page_url) { |n| "test#{n}@example.com/some_page" }
    sequence(:site_name) { |n| Constants::SITE_NAMES[n % Constants::SITE_NAMES.count] }
    sequence(:module_name) { |n| Constants::MODULE_NAMES[n % Constants::MODULE_NAMES.count] }
    original_view_count 10000
    posted_at DateTime.now - 2.day
    is_illust true

    to_create do |instance|
      instance.save validate: false
    end
  end


  # Creates an image that has actual image file.
  factory :image_file, class: Image do
    title 'madoka'
    caption 'madoka dayo!'
    sequence(:src_url) { |n| "test#{n}@example.com" }
    sequence(:created_at) { |n| Time.mktime(2014, 1, n, 0, 0, 0) }
    sequence(:page_url) { |n| "test#{n}@example.com/some_page" }
    sequence(:site_name) { |n| Constants::SITE_NAMES[n % Constants::SITE_NAMES.count] }
    sequence(:module_name) { |n| Constants::MODULE_NAMES[n % Constants::MODULE_NAMES.count] }
    original_view_count 10000
    posted_at DateTime.now
    is_illust true
    data { fixture_file_upload('spec/files/test_images/madoka0.jpg') }
    to_create do |instance|
      instance.save validate: false
    end

    after(:create) do |image|
      5.times do
        image.tags << create(:tag)
      end
    end
  end

  # Creates an image that is created older than :image factory
  factory :image_old, class: Image do
    title 'test'
    sequence(:src_url) { |n| "test_old#{n}.com" }
    created_at  Time.utc(2013, 12, 1, 0, 0, 0)
  end

  # Creates an image that is created newer than :image factory
  factory :image_new, class: Image do
    title 'test'
    sequence(:src_url) { |n| "test_new#{n}.com" }
    created_at  Time.utc(2014, 2, 1, 0, 0, 0)
    to_create do |instance|
      instance.save validate: false
    end
  end

  # Creates an image that has 'false' is_illust value
  factory :image_photo, class: Image do
    sequence(:src_url) { |n| "test_photo#{n}@example.com" }
    is_illust false

    to_create do |instance|
      instance.save validate: false
    end
  end

  # For testing Scrape::Nico.get_stats
  factory :image_nicoseiga, class: Image do
    src_url 'http://lohas.nicoseiga.jp/thumb/3932299i'
    page_url 'http://seiga.nicovideo.jp/seiga/im3932299'
    after(:create) do |image|
      image.tags = [ create(:tag) ]
    end
  end


  # ==============================
  #  Factories used in image_spec
  # ==============================
  # Creates an image that has 'Madoka Kaname' tags
  factory :image_madoka, class: Image do
    title 'Madoka Kaname(鹿目まどか)'
    caption '"For Madokami so loved the world that She gave us Her Only Self, that whoever believes in Her shall not despair but have everlasting Hope." --Homu 3:16'
    src_url 'http://i.4cdn.org/c/1399620027799.jpg'
    page_url 'http://boards.4chan.org/c/thread/2222110/madoka-kaname'
    data { fixture_file_upload('spec/files/test_images/madoka0.jpg') }

    after(:create) do |image|
      image.tags << create(:tag_madoka)
      image.tags << create(:tag_madoka_roman)
    end
  end

  factory :image_sayaka, class: Image do
    title 'Sayaka Miki'
    caption '"For Madokami so loved the world that She gave us Her Only Self, that whoever believes in Her shall not despair but have everlasting Hope." --Homu 3:16'
    src_url 'http://i.4cdn.org/c/1399620027799ssss.jpg'
    page_url 'http://boards.4chan.org/c/thread/2222110/madoka-kaname'
    data { fixture_file_upload('spec/files/test_images/madoka0.jpg') }

    after(:create) do |image|
      image.tags << create(:tag_sayaka)
      image.tags << create(:tag_sayaka_roman)
    end
  end

  # Creates an image that has both of 'Madoka Kaname' and 'single' tag
  factory :image_madoka_single, class: Image do
    title 'Madoka Kaname(鹿目まどか)'
    caption '"For Madokami so loved the world that She gave us Her Only Self, that whoever believes in Her shall not despair but have everlasting Hope." --Homu 3:16'
    src_url 'http://i.4cdn.org/c/some_single_madoka_image.jpg'
    page_url 'http://boards.4chan.org/c/thread/2222110/madoka-kaname'
    data { fixture_file_upload('spec/files/test_images/madoka0.jpg') }

    after(:create) do |image|
      # This factory is used together with 'image_madoka' factory
      image.tags << Tag.where(name: 'Madoka Kaname').first
      image.tags << Tag.where(name: 'Kaname Madoka').first
      image.tags << create(:tag_single)
    end
  end

  factory :image_sayaka_single, class: Image do
    title 'Sayaka Miki'
    caption '"For Madokami so loved the world that She gave us Her Only Self, that whoever believes in Her shall not despair but have everlasting Hope." --Homu 3:16'
    src_url 'http://i.4cdn.org/c/some_single_sayaka_image.jpg'
    page_url 'http://boards.4chan.org/c/thread/2222110/sayaka-miki'
    data { fixture_file_upload('spec/files/test_images/madoka0.jpg') }

    after(:create) do |image|
      # This factory is used together with 'image_madoka' factory
      image.tags << Tag.where(name: 'Sayaka Miki').first
      image.tags << Tag.where(name: 'Miki Sayaka').first
      image.tags << Tag.where(name: 'single').first
    end
  end

end