require 'spec_helper'

describe "Images" do
  describe "GET /images" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get images_path
      expect(response.status).to be(200)
    end
  end
end
