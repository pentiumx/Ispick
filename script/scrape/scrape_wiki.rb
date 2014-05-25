#-*- coding: utf-8 -*-
require 'nokogiri'
require 'open-uri'
require 'natto'


# wikipediaからアニメのキャラクター名を抽出する
module Scrape::Wiki
  require "#{Rails.root}/script/scrape/scrape_characters"
  include Character

  # 日本版Wikipedia URL
  ROOT_URL = 'http://ja.wikipedia.org/wiki/%E3%83%A1%E3%82%A4%E3%83%B3%E3%83%9A%E3%83%BC%E3%82%B8'

  # 関数定義
  # スクレイピングを行う
  def self.scrape
    puts 'Extracting : ' + ROOT_URL

    # 起点となるWikipediaカテゴリページのURL
    # URLはハードコードされているので、修正が必要
    url = [
      #'http://ja.wikipedia.org/wiki/Category:2009%E5%B9%B4%E3%81%AE%E3%83%86%E3%83%AC%E3%83%93%E3%82%A2%E3%83%8B%E3%83%A1',
      #'http://ja.wikipedia.org/wiki/Category:2010%E5%B9%B4%E3%81%AE%E3%83%86%E3%83%AC%E3%83%93%E3%82%A2%E3%83%8B%E3%83%A1',
      'http://ja.wikipedia.org/wiki/Category:2011%E5%B9%B4%E3%81%AE%E3%83%86%E3%83%AC%E3%83%93%E3%82%A2%E3%83%8B%E3%83%A1',
      #'http://ja.wikipedia.org/wiki/Category:2012%E5%B9%B4%E3%81%AE%E3%83%86%E3%83%AC%E3%83%93%E3%82%A2%E3%83%8B%E3%83%A1',
      #'http://ja.wikipedia.org/wiki/Category:2013%E5%B9%B4%E3%81%AE%E3%83%86%E3%83%AC%E3%83%93%E3%82%A2%E3%83%8B%E3%83%A1'
    ]

    # 各URLについて情報を取得
    url.each do |value|
      anime_page = self.get_anime_page(value)
      anime_character_page = Scrape::Wiki::Character.get_anime_character_page(anime_page)
      anime_character = Scrape::Wiki::Character.get_anime_character_name(anime_character_page)
      #self.hash_output(anime_character)  # テスト用
      self.save_to_database(anime_character)
    end

  end


  # アニメ名のハッシュを取得する
  # @param [String] 「20xx年のアニメ一覧」ページのurl
  # @return [Hash] アニメタイトルをkey、該当ページのurlをvalueとするhash
  def self.get_anime_page(url)
    anime_page = {}
    html = self.open_html url

    # アニメ名:アニメのページURLのハッシュを取得
    # カテゴリに分かれたページのURLを取得
    html.css('a').each do |item|
      if /Category/ =~ item['class']  or /CategoryTreeLabel/ =~ item['class']
        category_url = "http://ja.wikipedia.org%s" % [item['href']]
        #anime_page[item.inner_text] = self.get_category_anime_page(item.inner_text, category_url)
        page_url_ja = self.get_category_anime_page(item.inner_text, category_url)
        page_url_en = self.get_english_anime_page page_url_ja
        anime_page[item.inner_text] = { ja: page_url_ja, en: page_url_en }
      end
    end

    # ページ一覧からアニメURLを取得
    html.css('li > a').each do |item|
      if /アカウント/ =~ item.inner_text
        break
      end
      if /年(代)*の(テレビ)*(アニメ|番組)/ =~ item.inner_text or /履歴/ =~ item.inner_text
        next
      end
      if not item.inner_text == '' and not anime_page.has_key?(item.inner_text)
        puts page_url_ja = "http://ja.wikipedia.org%s" % [item['href']]
        page_url_en = self.get_english_anime_page page_url_ja
        anime_page[item.inner_text] = { ja: page_url_ja, en: page_url_en }
      end
    end

    html.css('span > a').each do |item|
      if /年(代)*の(テレビ)*(アニメ|番組)/ =~ item.inner_text
        next
      end
      if not item.inner_text.empty? and not anime_page.has_key?(item.inner_text)
        page_url_ja = "http://ja.wikipedia.org%s" % [item['href']]
        page_url_en = self.get_english_anime_page page_url_ja
        anime_page[item.inner_text] = { ja: page_url_ja, en: page_url_en }
      end
    end

    anime_page  # Hash
  end


  # 英語版ページへのリンクがある場合そのページurlを返す
  # @param [String] 日本語版ページのurl
  # @return [String] 英語版ページのurl
  def self.get_english_anime_page(anime_page)
    html = self.open_html anime_page
    return if html.nil?

    item = html.css("li[class='interlanguage-link interwiki-en']").first

    # liタグ内のaタグのリンクを調べる
    if item.nil?
      return ''
    else
      url = item.css('a').first.attr('href')
      return "http:#{url}"
    end
  end


  # カテゴリページ内からアニメのページURLを取得する
  # @param anime_title : String アニメのタイトル
  # @param category_url : String カテゴリページのURL
  def self.get_category_anime_page(anime_title, category_url)
    anime_page_url = ''
    return if category_url.empty?

    # カテゴリページの取得
    html = self.open_html category_url

    # aタグの取得
    html.css('a').each do |item|
      if anime_title == item.inner_text
        anime_page_url = "http://ja.wikipedia.org%s" % [item['href']]
        break
      end
    end

    anime_page_url  # String
  end

  # HTMLページを開いてNokogiriのHTMLオブジェクトを返す。
  # 例外が発生した場合はnilを返す
  # @param [String] 対象url
  # @return [Nokogiri::HTML] NokogiriでパースされたHTMLオブジェクト
  def self.open_html(url)
    begin
      html = Nokogiri::HTML(open(url))
    rescue OpenURI::HTTPError => e
      if e.message == '404 Not Found'
        puts '次のURLを開けませんでした'
        puts "URL : #{url}"
      else
        raise e
      end
    rescue Errno::ENOENT => e
      return puts e
    rescue SocketError => e
      return puts e
    end
  end


  # ハッシュ内容のファイル出力
  # @param [Hash] keyがアニメタイトル、valueが登場キャラクタの配列であるようなHash
  def self.hash_output(input_hash)
    f = open("sample.txt", "a")
    input_hash.each do |anime, characters|
      f.write(">> #{anime}\n")
      characters.each do |array|
        f.write("[")
        array.each do |value|
          f.write("#{value}, ")
        end
        f.write("]\n")
      end
      f.write("\n")
    end
  end


  # キャラクタ情報をparseしてPeopleテーブルへ保存する
  # @param [Hash] keyがアニメタイトル、valueが登場キャラクタの配列であるようなHash
  def self.save_to_database(input_hash)
    input_hash.each do |anime, characters|
      next if characters.nil?

      characters.each do |name_hash|
        # {:name=>"鹿目 まどか", :query=>"鹿目まどか", :_alias=>"かなめ まどか", :en=>"Madoka Kaname"}
        person = Person.create(
          name: name_hash[:query],
          name_display: name_hash[:name],
          name_english: name_hash[:en],
          name_type: 'Character'
        )

        # 関連キーワードとしてアニメタイトルを追加
        person.keywords.create(word: anime, is_alias: false)

        # Titleレコード追加
        title = Title.create(name: anime)
        title.people << person

        # よみがなをaliasとして追加
        person.keywords.create(word: name_hash[:_alias], is_alias: true)

        # keywords保存の例
        #person.keywords.create(word: 'まど', is_alias: true)     # createと同時に保存される
        #person.keywords.create(word: 'ピンク', is_alias: false)

        # mecab使用例
        # ref : http://qiita.com/k-shogo/items/0f8a98c52913c729c7eb
        #mecab = Natto::MeCab.new
        #mecab.parse('まどかだよっ！') do |n|
        #  puts n.surface # => まどか/だ/よ/っ/！　など
        #end
        # =>パフォーマンスに問題あり？ => C++/C#

        person.save!
      end
    end
  end


end