require 'spec_helper'
require "#{Rails.root}/app/services/target_images_service"
# Need to attach 'Rails.env.test?' or this crushes activeadmin pages.
# https://github.com/activeadmin/activeadmin/issues/512
include ActionDispatch::TestProcess if Rails.env.test?

describe TargetImagesService do
  let(:valid_attributes) { FactoryGirl.attributes_for(:target_image) }

# AnimeFace has been shut down since 2014/07/06
=begin
  describe "get_face_feature method" do
    it "returns face feature array of a image" do
      target_image = TargetImage.create! valid_attributes
      AnimeFace.stub(:detect).and_return(['a json array'])

      service = TargetImagesService.new
      service.get_face_feature(target_image.data.path).should be_an(Array)
    end
  end

  describe "prefer method" do
    it "returns list of images" do
      target_image = TargetImage.create! valid_attributes
      AnimeFace.stub(:detect).and_return(['a json array'])

      service = TargetImagesService.new
      list = service.prefer target_image
      list.should be_an(Hash)
    end
  end
=end

  describe "get_preferred_images" do
    it "returns a valid data" do
      face_feature = FactoryGirl.create(:feature_madoka)
      target_image = TargetImage.find(face_feature.featurable_id)

      service = TargetImagesService.new
      result = service.get_preferred_images(target_image)
      expect(result).to be_a(Hash)
      expect(result[:images]).to be_an(Array)
      expect(result[:target_colors]).to be_a(Hash)

      # check unique
      expect(result[:images].uniq.length).to eq(result[:images].length)
    end

    it "returns if target_image.feature is nil or '[]'" do
      target_image = FactoryGirl.create(:target_image)
      service = TargetImagesService.new
      result = service.get_preferred_images(target_image)
      expect(result).to eq('Feature of the target_image is invalid!')

      face_feature = FactoryGirl.create(:feature_test2)
      target_image = TargetImage.find(face_feature.featurable_id)
      service = TargetImagesService.new
      result = service.get_preferred_images(target_image)
      expect(result).to eq('Feature of the target_image is invalid!')

      face_feature = FactoryGirl.create(:feature_test3)
      target_image = TargetImage.find(face_feature.featurable_id)
      service = TargetImagesService.new
      result = service.get_preferred_images(target_image)
      expect(result).to eq('Feature of the target_image is invalid!')
    end

    describe "with single face" do
      it "returns a precise similar image that has similar hair color" do
        face_feature = FactoryGirl.create(:feature_madoka)
        target_image = TargetImage.find(face_feature.featurable_id)

        FactoryGirl.create(:feature_madoka1)
        service = TargetImagesService.new

        result = service.get_preferred_images(target_image)
        expect(result[:images].length).to eq(1)
      end
    end
=begin
    describe "with multiple faces" do
      # Recommend images based on all faces in an image
      it "returns precise preferred images to ALL target_images" do
        FactoryGirl.create(:feature_madoka_multi)
        FactoryGirl.create(:feature_homura_multi)
        face_feature = FactoryGirl.create(:feature_madoka_homura)
        target_image = TargetImage.find(face_feature.featurable_id)
        service = TargetImagesService.new

        # Both images are recommended
        result = service.get_preferred_images(target_image)
        result[:images].length.should eq(2)
      end
    end
=end

    describe "with already delivered target_image" do
      it "should ignore old images before last_delivered_at datetime" do
        FactoryGirl.create(:feature_image_old)
        FactoryGirl.create(:feature_image_new)
        face_feature = FactoryGirl.create(:feature_target_delivered)
        target_image = TargetImage.find(face_feature.featurable_id)

        service = TargetImagesService.new
        result = service.get_preferred_images(target_image)
        expect(result[:images].length).to eq(1)
      end
    end
  end

end