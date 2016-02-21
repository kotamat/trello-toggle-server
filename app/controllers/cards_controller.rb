require 'trello'
class CardsController < ApplicationController
  before_action :set_card, only: [:show, :edit, :update, :destroy]
  before_action :trello_setting
  protect_from_forgery with: :null_session
  NEW_LIST = "new"
  BOARD_ID = "FgLF9iac"


  # GET /cards
  # GET /cards.json
  def index
    @cards = Card.all
  end

  # GET /cards/1
  # GET /cards/1.json
  def show
  end

  # GET /cards/new
  def new
    @card = Card.new
  end

  # GET /cards/1/edit
  def edit
  end

  # POST /cards
  # POST /cards.json
  def create
    @card = Card.new(card_params)

    # trello add
    @lists = get_lists(BOARD_ID)
    new_list = @lists.find { |list| list.name == NEW_LIST }
    Trello::Card.create name: card_params[:name], board_id: BOARD_ID, list_id: new_list.id

    respond_to do |format|
      if @card.save
        format.html { redirect_to @card, notice: 'Card was successfully created.' }
        format.json { render :show, status: :created, location: @card }
      else
        format.html { render :new }
        format.json { render json: @card.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cards/1
  # PATCH/PUT /cards/1.json
  def update
    respond_to do |format|
      if @card.update(card_params)
        format.html { redirect_to @card, notice: 'Card was successfully updated.' }
        format.json { render :show, status: :ok, location: @card }
      else
        format.html { render :edit }
        format.json { render json: @card.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cards/1
  # DELETE /cards/1.json
  def destroy
    @card.destroy
    respond_to do |format|
      format.html { redirect_to cards_url, notice: 'Card was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_card
      @card = Card.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def card_params
      params.fetch(:card, {}).permit(:name)
    end

    def trello_setting
      Trello.configure do |config|
          config.developer_public_key = "ee1bc88f30d0ce70f488181f00ecb43c"
          config.member_token = "0e7697d52103a7dd1cd8499a7a7e1a0e543d0ea4fb6e3efbe191fa039b7a435d"
      end
    end

    def get_lists(board_id)
        lists = Trello.client.get "/board/#{board_id}/lists"
        Trello::List.parse lists
    end
end
