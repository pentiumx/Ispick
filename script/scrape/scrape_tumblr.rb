# -*- coding: utf-8 -*-
require 'tumblr_client'
#require 'tumblr_client/../tumblr/tagged'
require 'tumblr/tagged'
require 'securerandom'


# Tumblrから2次画像を抽出する
module Scrape::Tumblr

  # TwitterURL
  ROOT_URL = 'https://twitter.com'

  # 関数定義
  def self.scrape()
    puts 'Extracting : ' + ROOT_URL

    limit   = 100        # 取得するツイートの上限数
    count = Image.count

    # 全ての登録済みのTargetWordに対して新着画像を取得する
    # しかしながらTargetWord.count=10000とかになったら厳しいかも
    TargetWord.all.each do |target_word|
      # Person.nameで検索（e.g. "鹿目まどか"）
      # エイリアスも含めるならkeywords.eachする
      puts target_word.person.name
      self.scrape_with_keyword(target_word.person.name, limit)
    end

    puts 'Scraped: '+(Image.count-count).to_s
  end

  # 対象のハッシュタグを持つツイートの画像を抽出する
  def self.scrape_with_keyword(keyword, limit)
    client = self.get_client

    # キーワードを含むハッシュタグの検索
    image_data = self.get_images(client, keyword, limit)

    self.save(image_data)
  end

  def self.get_client
    Tumblr.configure do |config|
      config.consumer_key = CONFIG['tumblr_consumer_key']
      config.consumer_secret = CONFIG['tumblr_consumer_secret']
      #config.oauth_token = "access_token"
      #config.oauth_token_secret = "access_token_secret"
    end
    Tumblr::Client.new
  end

  def self.get_images(client, keyword, limit)
    image_data = []

    # limitで指定された数だけ画像を取得
    images = client.tagged(keyword)
    images.each do |image|
      #puts image
      #fsd

      #http://realotakuman.tumblr.com/post/80263089672/pixiv
      url = image['post_url']
      puts url
      html = Nokogiri::HTML(open(url))

      #likes = html.css("meta[name='if:Show Likes']").attr('content').content
      #likes = html.css('body').first.content.to_s.count('likes this')
      #likes = html.css("ol[class='notes']").first.content.to_s.count('likes this')
      begin
        # show:likesを設定しているページのみgetしてみる
        likes = html.css("ol[class='notes']").first.content.to_s.scan(/likes this/)
        #puts likes.count
      rescue => e
        # 非表示設定にしていてlikesが取れないページは諦める
        puts e
        next
      end

      hash = {
        title: 'tumblr' + SecureRandom.random_number(10**14).to_s,
        caption: image['caption'],
        src_url: image['photos'].first['original_size']['url'],
        page_url: image['post_url'],
        posted_at: image['date'],
        views: nil,
        favorites: likes.count,
        site_name: 'tumblr',
      }
      tags = image['tags'].map { |tag| Tag.new(name: tag) }

      #puts images['tags']
      image_data.push({ data: hash, tags: tags })
    end
    image_data
  end

  def self.save(image_data)
    # Imageモデル生成＆DB保存
    image_data.each do |value|
      puts "#{value[:data][:src_url]}"
      if not Scrape::is_duplicate(value[:src_url])
        # Tumblrの場合はtagsに検索したタグが含まれているはずなのでそのまま使う
        Scrape.save_image(value[:data], value[:tags])
      else
        puts 'Skipping a duplicate image...'
      end
    end
  end

end
