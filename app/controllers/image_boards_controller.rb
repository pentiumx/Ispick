class ImageBoardsController < ApplicationController
  before_action :set_image_board, only: [:show, :edit, :update, :destroy]

  # GET /image_boards
  # GET /image_boards.json
  def index
    @image_boards = ImageBoard.all
  end

  # GET /image_boards/1
  # GET /image_boards/1.json
  def show
  end

  # GET /image_boards/new
  def new
    @image_board = ImageBoard.new
    respond_to do |format|
      format.html
      format.js
    end
  end

  def boards
    @image = Image.find(params[:image])
    @board = ImageBoard.new
    @id = params[:id]
    respond_to do |format|
      format.html { render partial: 'shared/popover_board',
        locals: { image: @image, image_board: @board, html: @id } }
      format.js { render partial: 'boards' }
    end
  end


  # GET /image_boards/1/edit
  def edit
    respond_to do |format|
      format.html
      format.js { render partial: 'edit' }
    end
  end

  # POST /image_boards
  def create
    @image_board = ImageBoard.new(image_board_params)
    @image_board.save!
    current_user.image_boards << @image_board

    @image = Image.find(params[:image])
    @board = ImageBoard.new
    @id = params[:html_id]
    respond_to do |format|
      format.html { render nothing: true }
      format.js { render partial: 'image_boards/boards' }
    end
  end

  # PATCH/PUT /image_boards/1
  # PATCH/PUT /image_boards/1.json
  def update
    respond_to do |format|
      if @image_board.update(image_board_params)
        format.html { redirect_to boards_users_path }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @image_board.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /image_boards/1
  # DELETE /image_boards/1.json
  def destroy
    @image_board.destroy
    respond_to do |format|
      format.html { redirect_to boards_users_path }
      format.json { head :no_content }
    end
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image_board
      @image_board = ImageBoard.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def image_board_params
      params.require(:image_board).permit(:name)
    end
end
