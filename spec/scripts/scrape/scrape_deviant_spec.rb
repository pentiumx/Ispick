require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"

describe Scrape::Deviant do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  before do
    IO.any_instance.stub(:puts)
    # resqueにenqueueしないように
    Resque.stub(:enqueue).and_return
  end

  # R18コンテンツを判定する関数について
  describe "is_adult method" do
    it "should return true with mature content" do
      url = 'http://ugly-ink.deviantart.com/art/HAPPY-HALLOWEEN-266750603'
      html = Nokogiri::HTML(open(url))
      Scrape::Deviant.is_adult(html).should eq(true)
    end

    it "should return false with non-mature contents" do
      url = 'http://www.deviantart.com/art/Crossing-4-437129901'
      html = Nokogiri::HTML(open(url))
      Scrape::Deviant.is_adult(html).should eq(false)
    end
  end

  describe "get_contents method" do
    before do
      @image_data = {
        title: 'test',
        page_url: 'http://www.deviantart.com/art/Crossing-4-437129901'
      }
    end

    it "should create an image model from an image source" do
      Scrape::Deviant.stub(:is_adult).and_return(false)
      count = Image.count

      Scrape::Deviant.get_contents(@image_data)
      Image.count.should eq(count+1)
    end

    it "should NOT create an image model from a mature image" do
      Scrape::Deviant.stub(:is_adult).and_return(true)
      count = Image.count

      url = 'http://www.deviantart.com/art/Crossing-4-437129901'
      Scrape::Deviant.get_contents(@image_data)
      Image.count.should eq(count)
    end

    # 対象URLを開けなかったときログに書くこと
    it "should write a log when it fails to open the image page" do
      Rails.logger.should_receive(:info).with('Image model saving failed.')
      Scrape.should_not_receive(:save_image)

      url = 'not_existed_url'
      Scrape::Deviant.get_contents({title: 'test', src_url: url})
    end
  end

  describe "scrape method" do
    it "should call get_contents method at least 20 time" do
      Scrape::Deviant.stub(:get_contents).and_return()
      Scrape::Deviant.should_receive(:get_contents).at_least(20).times

      Scrape::Deviant.scrape()
    end
  end


  describe "get_stats function" do
    it "returns updated stats information" do
      page_url = 'http://www.deviantart.com/art/Madoka-201395121'
      result = Scrape::Deviant.get_stats(page_url)
      expect(result).to be_a(Hash)
    end
    # failしたらログに書く事
    it "writes a log when it fails to open the page" do
      Rails.logger.should_receive(:info).with('Could not open the page.')

      url = 'not_existed_url'
      Scrape::Deviant.get_stats(url)
    end
  end
end