require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"

describe Scrape::Piapro do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  before do
    allow_any_instance_of(IO).to receive(:puts)
    allow(Resque).to receive(:enqueue).and_return nil # resqueにenqueueしないように
    @agent = Scrape::Piapro.login
  end

  describe "get_illust_html function" do
    it "returns Nokogiri::HTML object" do
      html = Nokogiri::HTML(open('http://piapro.jp/illust/?categoryId=3'))
      item = html.css("a[class='i_image']")[0]

      page = Scrape::Piapro.get_illust_html(item)
      expect(page).to be_a(Nokogiri::HTML::Document)
    end

    # 対象URLを開けなかった時にログに書く事
    it "writes a log when it fails to open the image page" do
      expect(Rails.logger).to receive(:info).with('Could not open the page.')
      expect(Scrape).not_to receive(:save_image)

      url = 'not_existed_url'
      Scrape::Piapro.get_illust_html(url)
    end
  end

  describe "get_contents function" do
    it "creates an image model from image source" do
      # save_image functionが呼ばれるはず
      allow(Scrape).to receive(:save_image).and_return nil
      expect(Scrape).to receive(:save_image)

      # イラスト表示ページ
      url = 'http://piapro.jp/t/mdHE'
      Scrape::Piapro.get_contents(url, @agent, { title: 'test' })
    end

    it "writes a log when it fails to open the page" do
      allow(@agent).to receive(:get).and_raise
      expect(Rails.logger).to receive(:info).with('Could not open the page.')

      url = 'http://piapro.jp/t/mdHE'
      Scrape::Piapro.get_contents(url, @agent, { title: 'test' })
    end

    # Tag
    it "scrape multiple tags from the page" do
      # 複数タグが登録されているイラスト
      #html = Nokogiri::HTML(open('http://piapro.jp/t/uvW_'))
      #Scrape::Piapro.get_contents(html)
    end
  end

  describe "login function" do
    it "returns mechanize agent" do
      #agent = Scrape::Piapro.login()
      expect(@agent).to be_a(Mechanize)
    end
    it "returns page with logged in" do
      # ログイン後のページheaderに「ログイン」メニューは無い
      page = @agent.get('http://piapro.jp/')
      header = page.at("div[id='header_user']").content
      #puts header.match(/ログアウト/)
      match = header.match(/ログイン/)
      expect(match).to eql(nil)
    end
  end

  describe "scrape function" do
    it "should call get_contents method at least 30 time" do
      allow(Scrape::Piapro).to receive(:get_contents).and_return nil
      expect(Scrape::Piapro).to receive(:get_contents).at_least(30).times

      Scrape::Piapro.scrape()
    end
  end
end