require 'spec_helper'

describe "TargetWords" do
  describe "GET /target_words" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get target_words_path
      expect(response.status).to be(200)
    end
  end
end
