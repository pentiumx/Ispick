class Message < ActiveRecord::Base
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  validates :name, :email, :subject, :body, :presence => true
  validates :email, :format => { :with => %r{.+@.+\..+} }, :allow_blank => true

  #def initialize(attributes = {})
  #  attributes.each do |name, value|
  #    send("#{name}=", value)
  #  end
  #end

  def persisted?
    false
  end
end
