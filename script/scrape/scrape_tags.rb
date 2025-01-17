# coding: utf-8
require 'open-uri'
require 'securerandom'
MAX_PAGES=10
MAX_TAGS=1000
COUNT_MIN=10

module Scrape::Tags
  def self.scrape()
    tags = {}
    tags = self.from_anipic()

    # { "rumia"=>{:en=>"rumia", :rs=>"", :jp=>"ルーミア"}, "miku hatsune"=>{:en=>"miku hatsune", :rs=>"", :jp=>"初音ミク"}  }
    #puts tags

    puts "The total count of tags: #{tags.count}"
    self.save_to_database(tags)
  end

  def self.save_to_database(tags)
    tags.each do |key, value|
      Person.create(
        name: value[:jp],
        name_display: value[:jp],
        name_roman: value[:en],
        name_english: self.get_name_english(value[:en]),
        name_type: 'Character'
      )

      puts "Seeded: #{key}"
    end
  end

  def self.get_name_english(name_roman)
    tmp = name_roman.split(' ')
    return name_roman if tmp.count != 2

    return "#{tmp[1]} #{tmp[0]}"
  end


  # Anipicのキャラクター名のカウント順タグ一覧ページからタグを抽出（１ページあたり100タグ）
  # @return [Hash] キーが英名で英名・ロシア名・和名を持つ
  # Extract tags from tag index page of anime-pictures.net (100 tag per page)
  # @return [Hash] Key: English name, Value: English/Russian/Japanese names
  def self.from_anipic()
    root_url= "http://anime-pictures.net/"
    tags = {}
    url = "http://anime-pictures.net/pictures/view_all_tags/0?search_text=&tag_desc=&sort_by_num=1&filter_by=1&lang=en"

    html = Nokogiri::HTML(open(url))
    table = html.css("table[class='all_tags']")

    page_count = 0;
    name_count = 0;

    # 最大でMAX＿PAGES分だけタグを抽出
    # Extract as many tags as MAX_PAGES at maximum
    while page_count <= MAX_PAGES do

      # Get next page
      if page_count!=0 then
        html.css("p[class='numeric_pages']").css('a').each do |a|
          if a.content == '>' then
            url = root_url + a.attr('href')
            break
          end
        end
        html = Nokogiri::HTML(open(url))
        table = html.css("table[class='all_tags']")
      end

      table.css('tr').each do |tr|
        td = tr.css('td')
        # １列目は見出し(th)なのでNullClass
        # First row is a th tag, so it's nil
        if !td[4].nil? then
          # Extract tags which have count num more than COUNT_MIN
          if td[4].content.to_i >= COUNT_MIN then
            # Set English name as the key. Also remove strings inside '()' are removed
            name_en = td[1].content.gsub(/\(.*?\)+/,"")
            tags[name_en] = self.get_name(td)
            name_count = name_count+1
          end
        end

        # Finish if it reaches max tag num
        if name_count >= MAX_TAGS then
          page_count = MAX_PAGES
          break
        end
      end

      page_count=page_count+1
    end

    return tags
  end

  # @return [Hash]
  def self.get_name(td)
    # Get English name to Japanese name
    name_hash ={}
    for i in 1..3 do
      case i
      when 1 then
        key = :en
      when 2 then
        key = :rs
      when 3 then
        key = :jp
      else
      end

      # Remove strings inside the parentheses '()'
      name_hash[key] = td[i].content.gsub(/\(.*?\)+/,"")
    end

    return name_hash
  end

end
