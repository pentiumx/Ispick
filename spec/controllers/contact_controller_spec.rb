require 'spec_helper'

describe ContactController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'new'
      expect(response).to be_success
    end
  end

end
