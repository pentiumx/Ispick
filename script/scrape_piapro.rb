# coding: utf-8
require 'open-uri'

module Scrape::Piapro
  ROOT_URL = 'http://piapro.jp/'

  def self.get_contents(item)
    # リンク先がサイト内URLで表されているので、ROOT_URLと組み合わせてURL生成しアクセス
    begin
      page_url = item['href']
      root_img_url = URI.join(ROOT_URL, page_url).to_s
      page = Nokogiri::HTML(open(root_img_url))
    rescue Exception => e
      Rails.logger.info('Image model saving failed.')
      return
    end

    # ...style="background:url(http://c1.piapro.jp/xxx.png) no-repeat center;">
    # という文字列からURLを切り取る
    str = page.css("div[class='dtl_works dtl_ill']").first
    img_url = str['style'][/\((.*?)\)/] # (...)の中のurlを取り出す
    img_url = img_url.gsub(/[()]/, "")  # ()を除去
    puts img_url

    # Imageモデル生成＆DB保存
    if not Scrape::is_duplicate(img_url)
      Scrape::save_image(item.text, img_url)
    else
      puts 'Skipping a duplicate image...'
    end
  end

  # ピアプロは抽出しやすい
  def self.scrape()
    puts 'Extracting : ' + ROOT_URL

    # オフィシャルカテゴリに属するイラストの新着を見る
    url = 'http://piapro.jp/illust/?categoryId=3'
    html = Nokogiri::HTML(open(url))

    # class属性名が「i_image」であるタグに注目
    html.css("a[class='i_image']").each do |item|
      self.get_contents(item)
    end
  end

end