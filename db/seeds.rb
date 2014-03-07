# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

include ActionDispatch::TestProcess
require "#{Rails.root}/app/workers/images_face"

files = Dir["#{Rails.root}/spec/files/images/*"]
count = 0


files.each do |f|
  image = Image.new(title: 'seed data ' + count.to_s, data: fixture_file_upload(f), src_url: 'seeddata.com/'+count.to_s)

  begin
    if image.save
      Resque.enqueue(ImageFace, image.id)
    else
      puts 'failed.'
    end
  rescue Exception => e
    puts e
  end
  count += 1
end