require 'spec_helper'


describe UsersHelper do
  # ======================
  #  HTML related helpers
  # ======================
  describe "get_illust_html method" do
    it "returns a valid html" do
      image = FactoryGirl.create(:image)
      result = helper.get_illust_html(image)
      expect(result).to eql('Illust: <span><strong>true</strong></span>')
    end
  end

  describe "get_quality_html method" do
    it "returns a valid html" do
      image = FactoryGirl.create(:image)
      result = helper.get_quality_html(image)
      expect(result).to eql('Quality: <span><strong></strong></span>')
    end
  end

  describe "get_debug_html method" do
    it "returns a valid html" do
      #user = FactoryGirl.create(:user_with_images)
      #result = helper.get_debug_html(user.images)
      #expect(result).to eql("<strong>Found 2 images.</strong>")
    end
  end


  # ===================
  #  Rendering helpers
  # ===================
  describe "render_image_button" do
    it "returns a valid html" do
      image = FactoryGirl.create(:image)
      image = image
      result = helper.render_image(image)
      expect(result.class).to eq(ActiveSupport::SafeBuffer)
    end
  end

  describe "render_clip_button" do
    it "returns a valid html" do
      image = FactoryGirl.create(:image)
      result = helper.render_clip_button(image)
      expect(result.class).to eq(ActiveSupport::SafeBuffer)

      id = image.id
      html = "<a class=\"popover-board btn-info btn-sm btn\" data-container=\"body\" data-placement=\"bottom\" data-remote=\"true\" data-toggle=\"popover\" href=\"/image_boards/boards?id=popover-board#{id}&amp;image=#{id}\" id=\"popover-board#{id}\"><span class=\"glyphicon glyphicon-paperclip\" style=\"vertical-align:middle\"></span></a>"
      expect(result.to_s).to eq(html)
    end
  end

  describe "render_hide_button" do
    it "returns a valid html" do
      image = FactoryGirl.create(:image)
      result = helper.render_hide_button(image)
      expect(result.class).to eq(ActiveSupport::SafeBuffer)
    end
  end

  describe "render_show_button" do
    it "returns a valid html" do
      image = FactoryGirl.create(:image)
      result = helper.render_show_button(image)
      expect(result.class).to eq(ActiveSupport::SafeBuffer)
    end
  end

end
