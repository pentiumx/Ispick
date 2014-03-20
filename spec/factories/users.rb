# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com" }
    sequence(:password) { |n| "#{n}2345678" }
  end
  factory :twitter_user, class: User do
    sequence(:email) { |n| "test#{n}@example.com" }
    password '12345678'
    provider  'twitter'
    uid '12345678'

    factory :user_with_delivered_images do
      ignore do
        images_count 5
      end
      after(:create) do |user, evaluator|
        create_list(:delivered_image_file, evaluator.images_count, user: user)
      end
    end

    factory :user_with_target_images do
      ignore do
        images_count 5
      end
      after(:create) do |user, evaluator|
        create_list(:target_image, evaluator.images_count, user: user)
      end
    end

    factory :user_with_favored_images do
      ignore do
        images_count 5
      end
      after(:create) do |user, evaluator|
        create_list(:delivered_image_favored, evaluator.images_count, user: user)
      end
    end
  end
  factory :facebook_user, class: User do
    email 'test@example.com'
    password '12345678'
    provider  'facebook'
    uid '12345678'
  end

end