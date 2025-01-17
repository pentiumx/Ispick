require 'spec_helper'

describe "target_images/index" do
  before(:each) do
    assign(:target_images, Kaminari.paginate_array([
      stub_model(TargetImage,
        #:title => "Title"
      ),
      stub_model(TargetImage,
        #:title => "Title"
      )
    ]).page(1))
  end

  it "renders a list of target_images" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    #assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "img", count: 2
  end
end
