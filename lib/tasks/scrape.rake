# encoding: utf-8
require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/scrape/scrape_nico.rb"
require "#{Rails.root}/script/scrape/scrape_piapro.rb"
require "#{Rails.root}/script/scrape/scrape_4chan.rb"
require "#{Rails.root}/script/scrape/scrape_tumblr.rb"
require "#{Rails.root}/script/scrape/scrape_deviant.rb"
require "#{Rails.root}/script/scrape/scrape_giphy.rb"
require "#{Rails.root}/script/scrape/scrape_wiki.rb"
require "#{Rails.root}/script/scrape/scrape_tags.rb"
require "#{Rails.root}/script/scrape/scrape_anipic.rb"
require "#{Rails.root}/script/scrape/scrape_shushu.rb"
require "#{Rails.root}/script/scrape/scrape_zerochan.rb"
require "#{Rails.root}/script/scrape/scrape_pixiv.rb"

require 'fileutils'
require 'csv'


namespace :scrape do
  @DEFAULT_MN = 10000 # 10,000 images
  @DEFAULT_MO = 7     # 7 days

  # ==================================
  #           General tasks
  # ==================================
  # Delete images which have older created_at time than specified time
  desc "Delete images older than a certain date"
  task :delete_old, [:limit] => :environment do |t, args|
    puts 'Deleting old images...'
    if args[:limit]
      limit = args[:limit].to_i
    else
      limit = @DEFAULT_MO
    end
    before_count = Image.count

    # ref: http://stackoverflow.com/questions/755669/how-do-i-convert-datetime-now-to-utc-in-ruby
    old = DateTime.now.utc - limit.days
    Image.where("created_at < ?", old).destroy_all

    puts "Deleted: #{(before_count - Image.count).to_s} images"
    puts "Current image count: #{Image.count.to_s}"
  end

  # @params limit [Integer] Maximum limit to save images
  # If it exceeds the max limit, delete images from the oldest one,
  # and export deleted records attributes to old_record.txt
  desc "Delete images if its the count of all images exceeds the limit"
  task :delete_excess, [:limit] => :environment do |t, args|
    puts 'Deleting excessed images...'
    if args[:limit]
      limit = args[:limit].to_i
    else
      limit = @DEFAULT_MN
    end
    puts "limit: #{limit.to_s}"

    before_count = Image.count
    if Image.count > limit
      delete_num = Image.count - limit

    # Export images' attributes before it deletes them
=begin
      io = File.open("#{Rails.root}/log/old_record.txt","a")
      Image.reorder(:created_at).limit(delete_num).each do |image|
        str=""
        image.attributes.keys.each do |key|
          if !image[key].nil?
            str = str + key.to_s + ":\"" + image[key].to_s + "\","
          else
            str = str + key.to_s + ":\"nil\","
          end
        end
        str = str + "tags:\""
        image.tags.each do |tag|
          str = str + tag.name + "|"
        end
        str = str+"\""
        io.puts(str)
      end
      io.close
=end

      Image.reorder(:created_at).limit(delete_num).destroy_all
    end

    puts "Deleted: #{(before_count - Image.count).to_s} images"
    puts "Current image count: #{Image.count.to_s}"
  end

  # If it exceeds the max limit, delete images from the oldest one, only actual image filess
  # @param limit [Integer] Maximum limit to save images
  desc "Delete images if its the count of all images exceeds the limit"
  task :delete_excess_image_files, [:limit] => :environment do |t, args|
    puts "Deleting excessed image's files..."
    if args[:limit]
      limit = args[:limit].to_i
    else
      limit = @DEFAULT_MN
    end
    puts "limit: #{limit.to_s}"

    # The number of records that have images
    before_count = Image.where.not(data_file_size:nil).count
    if before_count > limit
      delete_num = before_count - limit
      Image.where.not(data_file_size:nil).reorder(:created_at).limit(delete_num).each do |image|
        image.destroy_image_files
      end
    end

    puts "Deleted: #{(before_count - Image.where.not(data_file_size:nil).count).to_s} image's files"
    puts "Current image count: #{Image.count.to_s}"
    puts "Number of images with not nil data: #{Image.where.not(data_file_size:nil).count}"
  end

  desc "Extract images from all target sites"
  task all: :environment do
    puts 'Scraping images from target websites...'
    Scrape.scrape_all
  end

  desc "Scrape images from all target webistes"
  task users: :environment do
    puts 'Scraping images from target websites...'
    Scrape.scrape_users
  end

  desc "Scrape images based on tag-search APIs, or search forms"
  task keyword: :environment do
    puts 'Scraping images from target websites...'
    Scrape.scrape_keyword(TargetWord.last)
  end

  desc "Redownload an image data which has nil src_url attribute"
  task redownload: :environment do
    puts 'Downloading for images with nil data...'
    Scrape.redownload
  end

  desc "Delete all people related tables COMPLETELY"
  task delete_people: :environment do
    puts 'Deleting all people related tables...'
    Person.delete_all
    Title.delete_all
    Keyword.delete_all
    PeopleKeyword.delete_all
    PeopleTitle.delete_all
  end

  desc "Delete images and target_words related tables COMPLETELY"
  task delete_all: :environment do
    puts 'Deleting all images / target_words related tables and image files...'

    # First, delete images and its files
    Image.delete_all
    begin
      FileUtils.rm_rf("#{Rails.root}/public/system/images")
    rescue => e
      puts "Failed to delete image files.\nPerhaps its already deleted."
    end

    # Then, delete other tables
    Tag.delete_all
    ImagesTag.delete_all
    TargetWord.delete_all
    TargetWordsUser.delete_all
  end


  # =======================================
  #  Tasks to scrape on the specific sites
  # =======================================
  desc "Construct static DB related to characters"
  task wiki: :environment do
    puts 'Scraping character names...'
    Scrape::Wiki.scrape_all
  end

  desc "Construct static DB related to anime titles"
  task wiki_titles: :environment do
    puts 'Scraping anime titles...'
    Scrape::Wiki.scrape_titles
  end

  desc "Scrape characters name tags from Anime Pictures"
  task tags: :environment do
    puts 'Scraping character names from anime-pictures.net...'
    Scrape::Tags.scrape
  end

  desc "Create TargetWord records for research"
  task people0: :environment do
    csv_text = File.read "#{Rails.root}/db/seeds/people0.csv"
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      Person.create!(row.to_hash)
    end
  end

  desc "Create TargetWord records for research"
  task hair_tags: :environment do
    hair_styles = [
      'side ponytail',
      'twintails',
    ]
  end


  # =======================================
  #   Tasks that scrape images from sites
  # =======================================
  desc "Scrape images from Nicoseiga"
  task :nico, [:interval] => :environment do |t, args|
    interval = args[:interval].nil? ? 120 : args[:interval]
    Scrape::Nico.new.scrape(interval.to_i)
  end

  desc "Scrape images from Piapro"
  task piapro: :environment do
    Scrape::Piapro.scrape
  end

  desc "Scrape images from 4chan"
  task fchan: :environment do
    Scrape::Fourchan.scrape
  end

  desc "Scrape images from Tumblr"
  task :tumblr, [:interval] => :environment do |t, args|
    interval = args[:interval].nil? ? 240 : args[:interval]
    Scrape::Tumblr.new.scrape(interval.to_i)
  end

  desc "Scrape images from deviantART"
  task deviant: :environment do
    Scrape::Deviant.new.scrape
  end

  desc "Scrape images from Giphy"
  task :giphy, [:interval] => :environment do |t, args|
    interval = args[:interval].nil? ? 720 : args[:interval]
    Scrape::Giphy.new.scrape(interval.to_i)
  end


  # Anime pictures and wallpapers
  desc "Scrape images from 'Anime pictures and wallpapers'"
  task :anipic, [:interval] => :environment do |t, args|
    interval = args[:interval].nil? ? 240 : args[:interval]
    Scrape::Anipic.new.scrape(interval.to_i)
  end

  desc "Scrape images from 'Anime pictures and wallpapers' using tags"
  task :anipic_tag, [:interval] => :environment do |t, args|
    interval = args[:interval].nil? ? 120 : args[:interval]
    Scrape::Anipic.new(nil, 1000).scrape_tag(interval.to_i)
  end

  # Zerochan
  desc "Scrape images from 'zerochan'"
  task :zerochan, [:interval] => :environment do |t, args|
    interval = args[:interval].nil? ? 240 : args[:interval]
    Scrape::Zerochan.new.scrape(interval.to_i)
  end

  desc "Scrape images from 'zerochan'"
  task :zerochan_tag, [:interval] => :environment do |t, args|
    interval = args[:interval].nil? ? 120 : args[:interval]
    Scrape::Zerochan.new(nil, 1000).scrape_tag(interval.to_i)
  end

  # E-shuushuu
  desc "Scrape images from 'Shushu'"
  task :shushu, [:interval] => :environment do |t, args|
    interval = args[:interval].nil? ? 240 : args[:interval]
    Scrape::Shushu.new.scrape(interval.to_i)
  end

  # Pixiv
  desc "Scrape images from 'Pixiv'"
  task :pixiv, [:interval] => :environment do |t, args|
    interval = args[:interval].nil? ? 240 : args[:interval]
    Scrape::Pixiv.new.scrape(interval.to_i)
  end

end
