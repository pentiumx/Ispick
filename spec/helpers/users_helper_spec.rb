require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the UsersHelper. For example:
#
# describe UsersHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
describe UsersHelper do
  describe "get_clip_string method" do
    it "returns valid string" do
      image = FactoryGirl.create(:delivered_image)
      expect(helper.get_clip_string(image)).to eq('Clip')

      image.update_attributes(favored: true)
      expect(helper.get_clip_string(image)).to eq('Unclip')
    end
  end

  describe "get_clip_string_styled" do
    it "returns valid string" do
      image = FactoryGirl.create(:delivered_image)
      expect(raw helper.get_clip_string_styled(image)).to eq('<span style="color: #000;">Clip</span>')

      image.update_attributes(favored: true)
      expect(raw helper.get_clip_string_styled(image)).to eq('<span style="color: #02C293;">Unclip</span>')
    end
  end
end