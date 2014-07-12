require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/scrape/scrape_tumblr"

describe Scrape::Tumblr do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  let(:response) { IO.read(Rails.root.join('spec', 'fixtures', 'tumblr_api_response')) }
  before do
    IO.any_instance.stub(:puts)             # コンソールに出力しないようにしておく
    Resque.stub(:enqueue).and_return nil    # resqueにenqueueしないように
    #@client = Scrape::Tumblr.get_client()
    @client = Scrape::Tumblr.new(nil, 5)
    #Rails.stub_chain(:logger, :debug).and_return(logger_mock)
    @response = JSON.parse(response)['response']
    @logger = Logger.new('log/scrape_tumblr_cron.log')
  end

  describe "scrape method" do
    it "calls scrape_target_words function" do
      FactoryGirl.create(:person_madoka)
      @client.stub(:scrape_target_words).and_return nil
      expect(@client).to receive(:scrape_target_words)

      @client.scrape(60)
    end
  end

  describe "scrape_target_word method" do
    it "calls scrape_using_api method" do
      target_word = FactoryGirl.create(:word_with_person)
      #puts Scrape::Tumblr.class
      #puts Scrape::Tumblr.any_instance.stub(:scrape_using_api).and_return({ scraped: 0, duplicates: 0, avg_time: 0 }).inspect
      @client.stub(:scrape_using_api).and_return({ scraped: 0, duplicates: 0, avg_time: 0 }) # => pass

      #client = Scrape::Tumblr.new
      expect(@client).to receive(:scrape_using_api)

      @client.scrape_target_word(1, target_word)
    end
  end


  describe "scrape_using_api function" do
    it "calls proper functions" do
      Tumblr::Client.any_instance.stub(:tagged).and_return(@response)

      # get_data functionをmockすると何故かcallされなくなるので、save_imageのみ見る
      #Scrape::Tumblr.should_receive(:get_data).exactly(5).times
      Scrape::Client.should_receive(:save_image).exactly(5).times
      target_word = FactoryGirl.create(:word_with_person)

      @client.scrape_using_api(target_word)
    end
  end

  describe "get_data function" do
    it "returns image_data hash" do
      image = {
        "blog_name"=>"realotakuman",
        "id"=>80263089672,
        "post_url"=>"http://realotakuman.tumblr.com/post/80263089672/pixiv",
        "date"=>"2014-03-21 14:54:12 GMT",
        "tags"=>["アナログ", "VOICEROID+", "結月ゆかり", "弦巻マキ"],
        "note_count"=>3,
        "caption"=>"blah blah",
        "photos"=>[{"original_size"=>{
          "width"=>697,
          "height"=>981,
          "url"=>"http://37.media.tumblr.com/9cbde1a610fd826c87600caa3372e176/tumblr_n2sk2cFwOB1qdwsovo1_1280.jpg"
          }}]
      }

      image_data = Scrape::Tumblr.get_data(image)
      expect(image_data).to be_a(Hash)
    end
  end


  describe "get_stats function" do
    it "returns a hash with favorites value" do
      post = FactoryGirl.build(:tumblr_api_response)
      Tumblr::Client.any_instance.stub(:posts).and_return(post[:response])
      page_url = 'http://realotakuman.tumblr.com/post/84103502875/twitter-kiya-si-http-t-co-mq1t'
      stats = Scrape::Tumblr.get_stats(page_url)

      expect(stats).to be_a(Hash)
      expect(stats[:favorites]).to eql(post[:response]['posts'][0]['note_count'])
    end
  end

  describe "get_client function" do
    it "returns tumblr client" do
      client = Scrape::Tumblr.get_client
      client.class.should eq(Tumblr::Client)
    end
  end

  describe "get_favorites function" do
    it "returns favorites count of the post" do
      page_url = 'http://senshi.org/post/82331944259/miku-x-cat-by-kenji'
      puts result = @client.get_favorites(page_url)
      expect(result).not_to eql(nil)
    end
  end
end