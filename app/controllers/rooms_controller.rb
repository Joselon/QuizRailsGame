class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room, only: [ :show, :start, :finish, :destroy ]

  def index
    @rooms = Room.all
    @active_rooms = Room.where.not(status: :finished)
    @finished_rooms = Room.where(status: :finished)
  end

  def show
     respond_to do |format|
      format.turbo_stream do
        Turbo::StreamsChannel.broadcast_replace_to(
          "room_#{@room.id}",
          target: "status-panel",
          partial: "rooms/status_panel",
          locals: { room: @room }
        )
        head :ok
      end
      format.html
    end
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

  def start
    if @room.waiting?
      @room.update(status: :rolling_for_order)
    end
    Turbo::StreamsChannel.broadcast_replace_to(
          "room_#{@room.id}",
          target: "status-panel",
           partial: "rooms/status_panel",
          locals: { room: @room }
    )
    respond_to do |format|
      format.turbo_stream { head :ok }
      format.html { redirect_to @room }
    end
  end

  def finish
    if @room.playing?
      @room.finished!
    end
        Turbo::StreamsChannel.broadcast_replace_to(
          "room_#{@room.id}",
          target: "status-panel",
           partial: "rooms/status_panel",
          locals: { room: @room }
    )
    respond_to do |format|
      format.turbo_stream { head :ok }
      format.html { redirect_to @room }
    end
  end

  def destroy
    @room.destroy
    respond_to do |format|
      format.turbo_stream do
        # TODO update room list
      end
      format.html { redirect_to rooms_path, notice: "Sala eliminada correctamente." }
    end
  end

  private

  def room_params
    params.require(:room).permit(:name, :status)
  end

  def set_room
    @room = Room.find(params[:id])
  end
end
