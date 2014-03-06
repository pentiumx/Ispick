class AddAttachmentDataToImages < ActiveRecord::Migration
  def self.up
    change_table :images do |t|
      t.attachment :data
    end
  end

  def self.down
    drop_attached_file :images, :data
  end
end
