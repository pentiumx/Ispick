# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  # A user which is created via an email address
  factory :user do
    sequence(:email) { |n| "test_user#{n}@example.com" }
    sequence(:password) { |n| "#{n}2345678" }
    sequence(:name) { |n| "ispick#{n}" }

    # Create a default FavoredImage object of the user
    after(:create) do |user|
      1.times { create(:favored_image_file, image_board: user.image_boards.first) }
      user.authorizations << create(:authorization)
    end
  end

  # Creates user objects with model callbacks
  factory :user_with_callbacks, class: User do
    sequence(:email) { |n| "test#{n}@example.com" }
    password '12345678'
    provider  'twitter'
    uid '12345678'
    sequence(:name) { |n| "ispick_twitter#{n}" }
  end

  # A user which is created via a facebook account
  factory :facebook_user, class: User do
    email 'test@example.com'
    password '12345678'
    provider  'facebook'
    uid '12345678'
    sequence(:name) { |n| "ispick_facebook#{n}" }
  end

  # A user which is created via a twitter account
  factory :twitter_user, class: User do
    sequence(:email) { |n| "test#{n}@example.com" }
    password '12345678'
    provider  'twitter'
    uid '12345678'
    sequence(:name) { |n| "ispick_twitter#{n}" }

    # Create default data including a favorite image
    after(:create) do |user|
      1.times do
        create(:favored_image_file, image_board: user.image_boards.first)
        user.image_boards << create(:image_board_min)
        user.authorizations << create(:authorization)
        user.authorizations << create(:authorization_tumblr)
      end
    end

    # ==========================
    #  Users with target_images
    # ==========================
    factory :user_with_target_images do
      sequence(:name) { |n| "ispick_twitter_i#{n}" }
      ignore do
        images_count 5
      end
      after(:create) do |user, evaluator|
        create_list(:target_image, evaluator.images_count, user: user)
      end
    end


    # ==============================
    #  Users with tags only
    # ==============================
    factory :user_with_tags do
      sequence(:name) { |n| "ispick_twitter_w#{n}" }
      uid '22345678'
      ignore do
        tags_count 5
      end
      after(:create) do |user, evaluator|
        5.times do
          user.tags << create(:tags)
        end
      end
    end

    factory :user_with_tag do
      sequence(:name) { |n| "ispick_twitter_w#{n}" }
      uid '22345678'
      after(:create) do |user|
        1.times do
          user.tags << create(:tags)
        end
      end
    end


    # ==========================================
    #  Users with tags that have images
    # ==========================================
    factory :user_with_tag_images do
      sequence(:name) { |n| "ispick_twitter_w#{n}" }
      ignore do
        images_count 1
      end
      after(:create) do |user, evaluator|
        1.times do
          user.tags << create(:tag_with_images, images_count: evaluator.images_count)
        end
      end
    end

    factory :user_with_tag_images_file do
      sequence(:name) { |n| "ispick_twitter_w#{n}" }
      ignore do
        images_count 1
      end
      after(:create) do |user, evaluator|
        1.times do
          user.tags << create(:tag_with_image_file, images_count: evaluator.images_count)
        end
      end
    end

    factory :user_with_tag_dif_image do
      sequence(:name) { |n| "ispick_twitter_w#{n}" }
      after(:create) do |user|
        1.times do
          user.tags << create(:tag_with_images)
          user.tags << create(:tag_with_image_dif_time)
          #user.tags << create(:tag_with_image_photo)
        end
      end
    end

  end # factory :twitter_user
end
