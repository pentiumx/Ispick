require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"

describe Scrape::Pixiv do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  before do
    #allow_any_instance_of(IO).to receive(:puts)
    allow(Resque).to receive(:enqueue).and_return nil
    @client = Scrape::Pixiv.new
    @agent = @client.get_client
  end

  describe "get_contents method" do
    it "should create an image model from image source" do
      count = Image.count
      uri = URI.parse('http://spapi.pixiv.net/iphone/search.php?s_mode=s_tag&word=%E3%81%BE%E3%81%A9%E3%81%8B%E3%82%8F%E3%81%84%E3%81%84&PHPSESSID=0')
      result = Net::HTTP.get(uri)
      lines = result.split("\n")

      Scrape::Pixiv.get_contents(lines[0])
      expect(Image.count).to eq(count+1)
    end
  end

  describe "scrape method" do
    it "should call get_contents method at least 1 time" do
      allow(Scrape::Pixiv).to receive(:get_contents).and_return nil
      expect(Scrape::Pixiv).to receive(:get_contents).at_least(20).times

      Scrape::Pixiv.scrape
    end
  end

  describe "get_tags_original method" do
    it "Get user oriented tags" do
      page_url = 'http://www.pixiv.net/member_illust.php?mode=medium&illust_id=48295800'
      page = @agent.get(page_url)

      tags = @client.get_tags_original(page)
      correct = ['ナルヒナ','日向ハナビ','サイいの','どんな下着だったのかkwsk','NARUTO100users入り','NARUTO','策士ハナビ','NARUTO1000users入り']
      puts tags

      expect(tags).to eq(correct)
    end
  end

  describe "get_src_url method" do
    it "returns valid src_url" do
      page_url = 'http://www.pixiv.net/member_illust.php?mode=medium&illust_id=48287081'
      illust_id = '48287081'

      result = @client.get_src_url(page_url, illust_id)
      expect(result).to eq('http://i2.pixiv.net/c/480x960/img-master/img/2015/01/21/01/16/33/48287081_480mw.jpg')
    end
  end
end