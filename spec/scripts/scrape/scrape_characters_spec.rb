#-*- coding: utf-8 -*-
require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/scrape/scrape_wiki"
require "#{Rails.root}/script/scrape/scrape_characters"
include Scrape::Wiki::Character

describe "Scrape::Wiki::Character" do
  before do
    IO.any_instance.stub(:puts)
  end

  describe "scrape character pages, then extract character names" do
    it "returns a proper array" do
      anime_page = {
        "魔法少女まどか☆マギカ"=>{:ja=>"http://ja.wikipedia.org/wiki/%E9%AD%94%E6%B3%95%E5%B0%91%E5%A5%B3%E3%81%BE%E3%81%A9%E3%81%8B%E2%98%86%E3%83%9E%E3%82%AE%E3%82%AB", :en=>"http://en.wikipedia.org/wiki/Puella_Magi_Madoka_Magica"}
      }

      #
      #url = 'http://ja.wikipedia.org/wiki/%E9%AD%94%E6%B3%95%E5%B0%91%E5%A5%B3%E3%81%BE%E3%81%A9%E3%81%8B%E2%98%86%E3%83%9E%E3%82%AE%E3%82%AB'
      #puts CGI.unescape(url)
      #http://ja.wikipedia.org/wiki/%E9%AD%94%E6%B3%95%E5%B0%91%E5%A5%B3%E3%81%BE%E3%81%A9%E%203%81%8B%E2%98%86%E3%83%9E%E3%82%AE%E3%82%AB
      #http://ja.wikipedia.org/wiki/%E9%AD%94%E6%B3%95%E5%B0%91%E5%A5%B3%E3%81%BE%E3%81%A9%E3%81%8B%E2%98%86%E3%83%9E%E3%82%AE%E3%82%AB

      puts anime_character_page = Scrape::Wiki::Character.get_anime_character_page(anime_page, false)

      # キャラクタ名の一覧配列を取得
      puts anime_character = Scrape::Wiki::Character.get_anime_character_name(anime_character_page, false)
    end
  end


  describe "get_anime_character_page function" do
    it "returns a valid hash" do
      url_ja = 'http://ja.wikipedia.org/wiki/%E9%AD%94%E6%B3%95%E5%B0%91%E5%A5%B3%E3%81%BE%E3%81%A9%E3%81%8B%E2%98%86%E3%83%9E%E3%82%AE%E3%82%AB'
      url_en = 'http://en.wikipedia.org/wiki/Puella_Magi_Madoka_Magica'
      url_ja0 = 'http://ja.wikipedia.org/wiki/%E3%81%95%E3%82%88%E3%81%AA%E3%82%89%E7%B5%B6%E6%9C%9B%E5%85%88%E7%94%9F'
      url_en0 = 'http://en.wikipedia.org/wiki/Sayonara,_Zetsubou-Sensei'
      page_hash = {
        '魔法少女まどか☆マギカ' => { ja: url_ja, en: url_en },
        'さよなら絶望先生' => { ja: url_ja0, en: url_en0 }
      }
      valid_hash = {
        "さよなら絶望先生"=>{:ja=>"http://ja.wikipedia.org/wiki/%E3%81%95%E3%82%88%E3%81%AA%E3%82%89%E7%B5%B6%E6%9C%9B%E5%85%88%E7%94%9F%E3%81%AE%E7%99%BB%E5%A0%B4%E4%BA%BA%E7%89%A9", :en=>"http://en.wikipedia.org/wiki/List_of_Sayonara,_Zetsubou-Sensei_characters", :title_en=>"Sayonara, Zetsubou-Sensei"},
        "魔法少女まどか☆マギカ"=>
          {:ja=>"http://ja.wikipedia.org/wiki/%E9%AD%94%E6%B3%95%E5%B0%91%E5%A5%B3%E3%81%BE%E3%81%A9%E3%81%8B%E2%98%86%E3%83%9E%E3%82%AE%E3%82%AB%E3%81%AE%E3%82%AD%E3%83%A3%E3%83%A9%E3%82%AF%E3%82%BF%E3%83%BC%E4%B8%80%E8%A6%A7",
            :en=>"http://en.wikipedia.org/wiki/List_of_Puella_Magi_Madoka_Magica_characters", :title_en=>"Puella Magi Madoka Magica"
          }
      }

      puts result = Scrape::Wiki::Character.get_anime_character_page(page_hash)
      expect(result).to be_a(Hash)
      expect(result).to eq(valid_hash)
    end
  end

  describe "get_character_page_ja function" do
    it "returns the hash that contains characters page url if characters list page exists" do
      # Use the url that contains the character list page link.
      # 「登場人物」の項が概要ページに存在するurl
      url = 'http://ja.wikipedia.org/wiki/%E3%81%93%E3%81%B0%E3%81%A8%E3%80%82'
      #url = 'http://ja.wikipedia.org/wiki/IS_%E3%80%88%E3%82%A4%E3%83%B3%E3%83%95%E3%82%A3%E3%83%8B%E3%83%83%E3%83%88%E3%83%BB%E3%82%B9%E3%83%88%E3%83%A9%E3%83%88%E3%82%B9%E3%80%89'
      html = Scrape::Wiki.open_html(url)
      puts result = Scrape::Wiki::Character.get_character_page_ja('こばと。', url, html)

      # get_anime_character_pageで拾う仕様なので、ここではempty hashを返す
      expect(result).to eql({ title: 'こばと。',
        url: 'http://ja.wikipedia.org/wiki/%E3%81%93%E3%81%B0%E3%81%A8%E3%80%82' })
    end

    it "returns a valid hash with external links" do
      # 「登場人物」の項が概要ページに存在するurl
      url = 'http://ja.wikipedia.org/wiki/%E9%AD%94%E6%B3%95%E5%B0%91%E5%A5%B3%E3%81%BE%E3%81%A9%E3%81%8B%E2%98%86%E3%83%9E%E3%82%AE%E3%82%AB'
      html = Scrape::Wiki.open_html(url)
      puts result = Scrape::Wiki::Character.get_character_page_ja('魔法少女まどか☆マギカ', url, html)
      expect(result).to eql({ title: '魔法少女まどか☆マギカ',
        url: 'http://ja.wikipedia.org/wiki/%E9%AD%94%E6%B3%95%E5%B0%91%E5%A5%B3%E3%81%BE%E3%81%A9%E3%81%8B%E2%98%86%E3%83%9E%E3%82%AE%E3%82%AB%E3%81%AE%E3%82%AD%E3%83%A3%E3%83%A9%E3%82%AF%E3%82%BF%E3%83%BC%E4%B8%80%E8%A6%A7' })
    end
  end

  describe "get_character_page_en function" do
    it "returns a valid Hash value" do
      url = 'http://en.wikipedia.org/wiki/Puella_Magi_Madoka_Magica'
      html = Scrape::Wiki.open_html url

      puts result = Scrape::Wiki::Character.get_character_page_en('Puella Magi Madoka Magica', url, html)
      #puts result = Scrape::Wiki::Character.get_character_page_en('魔法少女まどか☆マギカ', url, html)
      expect(result).to eql({ title: 'Puella Magi Madoka Magica',
        url: 'http://en.wikipedia.org/wiki/List_of_Puella_Magi_Madoka_Magica_characters'})
    end
  end


  describe "get_anime_character_name function" do
    it "returns a valid Hash value" do
      url_ja = 'http://ja.wikipedia.org/wiki/%E9%AD%94%E6%B3%95%E5%B0%91%E5%A5%B3%E3%81%BE%E3%81%A9%E3%81%8B%E2%98%86%E3%83%9E%E3%82%AE%E3%82%AB%E3%81%AE%E3%82%AD%E3%83%A3%E3%83%A9%E3%82%AF%E3%82%BF%E3%83%BC%E4%B8%80%E8%A6%A7'
      url_en = 'http://en.wikipedia.org/wiki/List_of_Puella_Magi_Madoka_Magica_characters'
      wiki_url = { '魔法少女まどか☆マギカ' => { ja: url_ja, en: url_en } }

      puts result = Scrape::Wiki::Character.get_anime_character_name(wiki_url)
      expect(result).to be_a(Hash)
      puts result['魔法少女まどか☆マギカ']
      expect(result['魔法少女まどか☆マギカ'][:characters].first[:en]).to eq('Madoka Kaname')
    end

=begin
    it "test" do
     hash = {'FF10' => {ja:"http://ja.wikipedia.org/wiki/%E3%83%95%E3%82%A1%E3%82%A4%E3%83%8A%E3%83%AB%E3%83%95%E3%82%A1%E3%83%B3%E3%82%BF%E3%82%B8%E3%83%BCX",
      en:"http://en.wikipedia.org/wiki/Characters_of_Final_Fantasy_X_and_X-2"}}
     puts(hash)
     result = Scrape::Wiki::Character.get_anime_character_name(hash)
     puts(result)
    end
=end
  end

  describe "get_character_name_ja funciton" do
    it "returns a hash that contains valid character names" do
      # 登場人物一覧ページ
      url = 'http://ja.wikipedia.org/wiki/%E9%AD%94%E6%B3%95%E5%B0%91%E5%A5%B3%E3%81%BE%E3%81%A9%E3%81%8B%E2%98%86%E3%83%9E%E3%82%AE%E3%82%AB%E3%81%AE%E3%82%AD%E3%83%A3%E3%83%A9%E3%82%AF%E3%82%BF%E3%83%BC%E4%B8%80%E8%A6%A7'
      html = Scrape::Wiki.open_html url

      result = Scrape::Wiki::Character.get_character_name_ja('魔法少女まどか☆マギカ', html)
      expect(result).to be_an(Array)
      #result.each { |n| puts n.class.name } # => Array
      result.each { |n| puts n }
    end
  end

  describe "get_character_name_en funciton" do
    it "returns a hash that contains valid character names" do
      # 登場人物一覧ページ
      url = 'http://en.wikipedia.org/wiki/List_of_Puella_Magi_Madoka_Magica_characters'
      html = Scrape::Wiki.open_html url
      characters_list = [
        {:name=>"鹿目 まどか", :query=>"鹿目まどか", :_alias=>"かなめ まどか"},
        {:name=>"暁美 ほむら", :query=>"暁美ほむら", :_alias=>"あけみ ほむら"},
        {:name=>"美樹 さやか", :query=>"美樹さやか", :_alias=>"みき さやか"},
        {:name=>"巴 マミ", :query=>"巴マミ", :_alias=>"ともえ マミ"},
        {:name=>"佐倉 杏子", :query=>"佐倉杏子", :_alias=>"さくら きょうこ"},
        {:name=>"キュゥべえ", :query=>"キュゥべえ", :_alias=>""}
      ]

      puts result = Scrape::Wiki::Character.get_character_name_en(
        '魔法少女まどか☆マギカ', html, characters_list)
      #result.each { |n| puts "#{n.count}, #{n}" }
      expect(result).to be_a(Array)
      expect(result.count).to eq(6)
    end
  end

  describe "match_character_name function" do
    it "returns a valid hash" do
      name_string = '(鹿目 まどか, Kaname Madoka)'
      characters_list =[{ name: '鹿目 まどか' }, { name: '美樹 さやか' }]
      puts result = Scrape::Wiki::Character.match_character_name(name_string, characters_list)
      expect(result).to eq({ name: '鹿目 まどか' })
    end
  end
end
