require 'spec_helper'

describe "Top page" do
  it "display title" do
    visit root_path
    expect(page).to have_css('h1', text: 'Ispick prototype v2')
  end

  it "login with oauth" do
    visit root_path
    mock_auth_hash
    click_link 'twitterでログイン'
    #save_and_open_page

    # users/homeに移動しているはず
    expect(page).to have_content("TODAY's Delivered Images")
  end
end