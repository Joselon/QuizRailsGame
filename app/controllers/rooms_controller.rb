class RoomsController < ApplicationController
  before_action :authenticate_user!

  def index
    @rooms = Room.all
  end

  def show
    @room = Room.find(params[:id])
  end

  def new
    @room = Room.new
  end

  def create
    @room = Room.new(room_params)
    if @room.save
      @room.room_players.create(user: current_user, score: 0, turn_order: 0)
      redirect_to @room
    else
      render :new
    end
  end

  private

  def room_params
    params.require(:room).permit(:name, :status)
  end
end
