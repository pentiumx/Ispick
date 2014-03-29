class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.text :title
      t.text :caption
      t.text :src_url
      t.attachment :data

      t.timestamps
    end
  end
end
