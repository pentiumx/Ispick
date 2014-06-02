require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe ImageBoardsController, :type => :controller do

  # This should return the minimal set of attributes required to create a valid
  # ImageBoard. As you add validations to ImageBoard, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ImageBoardsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all image_boards as @image_boards" do
      image_board = ImageBoard.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:image_boards)).to eq([image_board])
    end
  end

  describe "GET show" do
    it "assigns the requested image_board as @image_board" do
      image_board = ImageBoard.create! valid_attributes
      get :show, {:id => image_board.to_param}, valid_session
      expect(assigns(:image_board)).to eq(image_board)
    end
  end

  describe "GET new" do
    it "assigns a new image_board as @image_board" do
      get :new, {}, valid_session
      expect(assigns(:image_board)).to be_a_new(ImageBoard)
    end
  end

  describe "GET edit" do
    it "assigns the requested image_board as @image_board" do
      image_board = ImageBoard.create! valid_attributes
      get :edit, {:id => image_board.to_param}, valid_session
      expect(assigns(:image_board)).to eq(image_board)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ImageBoard" do
        expect {
          post :create, {:image_board => valid_attributes}, valid_session
        }.to change(ImageBoard, :count).by(1)
      end

      it "assigns a newly created image_board as @image_board" do
        post :create, {:image_board => valid_attributes}, valid_session
        expect(assigns(:image_board)).to be_a(ImageBoard)
        expect(assigns(:image_board)).to be_persisted
      end

      it "redirects to the created image_board" do
        post :create, {:image_board => valid_attributes}, valid_session
        expect(response).to redirect_to(ImageBoard.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved image_board as @image_board" do
        post :create, {:image_board => invalid_attributes}, valid_session
        expect(assigns(:image_board)).to be_a_new(ImageBoard)
      end

      it "re-renders the 'new' template" do
        post :create, {:image_board => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested image_board" do
        image_board = ImageBoard.create! valid_attributes
        put :update, {:id => image_board.to_param, :image_board => new_attributes}, valid_session
        image_board.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested image_board as @image_board" do
        image_board = ImageBoard.create! valid_attributes
        put :update, {:id => image_board.to_param, :image_board => valid_attributes}, valid_session
        expect(assigns(:image_board)).to eq(image_board)
      end

      it "redirects to the image_board" do
        image_board = ImageBoard.create! valid_attributes
        put :update, {:id => image_board.to_param, :image_board => valid_attributes}, valid_session
        expect(response).to redirect_to(image_board)
      end
    end

    describe "with invalid params" do
      it "assigns the image_board as @image_board" do
        image_board = ImageBoard.create! valid_attributes
        put :update, {:id => image_board.to_param, :image_board => invalid_attributes}, valid_session
        expect(assigns(:image_board)).to eq(image_board)
      end

      it "re-renders the 'edit' template" do
        image_board = ImageBoard.create! valid_attributes
        put :update, {:id => image_board.to_param, :image_board => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested image_board" do
      image_board = ImageBoard.create! valid_attributes
      expect {
        delete :destroy, {:id => image_board.to_param}, valid_session
      }.to change(ImageBoard, :count).by(-1)
    end

    it "redirects to the image_boards list" do
      image_board = ImageBoard.create! valid_attributes
      delete :destroy, {:id => image_board.to_param}, valid_session
      expect(response).to redirect_to(image_boards_url)
    end
  end

end
