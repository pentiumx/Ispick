require 'spec_helper'

describe UsersController do
  let(:valid_session) { {} }
  after do
    sign_out :user
  end

  describe "GET home" do
    it "renders 'signin_with_password' template when the user is NOT logged in" do
      get :home, {}, valid_session
      expect(response).to redirect_to('/signin_with_password')
    end

    it "renders 'home' template when the user is logged in" do
      login_user
      get :home, {}, valid_session
      expect(response).to render_template('home')
    end

    it "does something" do
      login_user
      get :home, { date: 'Mon Sep 01 2014 00:00:00 GMT 0900 (JST)' }, valid_session
    end
  end


  describe "GET show_target_images" do
    it "renders show_target_images template when logged in" do
      login_user
      get :show_target_images, {}, valid_session
      response.should render_template('show_target_images')
    end

    it "renders not_signed_in template when NOT logged in" do
      get :show_target_images, {}, valid_session
      expect(response).to redirect_to('/signin_with_password')
    end
  end

  describe "GET show_target_words" do
    it "renders 'preferences' template when logged in" do
      login_user
      get :preferences, {}, valid_session
      response.should render_template('preferences')
    end

    it "renders 'not_signed_in' template when NOT logged in" do
      get :preferences, {}, valid_session
      expect(response).to redirect_to('/signin_with_password')
    end
  end

  describe "GET boards" do
    it "renders show_target_images template when logged in" do
      login_user
      get :boards, {}, valid_session
      response.should render_template('boards')
    end

    it "renders not_signed_in template when NOT logged in" do
      get :boards, {}, valid_session
      expect(response).to redirect_to('/signin_with_password')
    end
  end

  describe "GET download_favored_images" do
    # see: http://stackoverflow.com/questions/4701108/rspec-send-file-testing
    it "downloads favored delivered_images" do
      login_user
      controller.stub(:render).and_return nil
      controller.should_receive(:send_file)#.and_return(nil)#{ controller.render nothing: true }
      get :download_favored_images, {}, valid_session
    end
  end

  # An action for debug
  describe "GET debug_illust_detection" do
    it "renders valid template" do
      login_user
      get :debug_illust_detection, {}, valid_session
      response.should render_template('debug_illust_detection')
    end
  end


  # ==========================
  #  specs of private methods
  # ==========================
=begin
  describe "update_session" do
    controller = UsersController.new
    puts "#{User.count} #{DeliveredImage.count}"
    puts controller.session
    params = { all: true, sort: true }

    result = controller.send(:update_session, params)
    puts result.count
  end
=end

end
