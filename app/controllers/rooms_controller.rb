class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room, only: [ :show, :start, :finish, :destroy ]

  include ActionView::RecordIdentifier

  def index
    @rooms = Room.all
    @active_rooms = Room.where.not(status: :finished)
    @finished_rooms = Room.where(status: :finished)
  end

  def show
    @game = GameManager.for(@room)
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
    @game = GameManager.for(@room)

    if @room.waiting?
      @game.start_turn_order_phase!
    end

    @game.broadcast_room_update(current_user)

    respond_to do |format|
      format.turbo_stream { head :ok }
      format.html { redirect_to @room }
    end
  end

  def finish
    @game = GameManager.for(@room)
    if @room.playing?
      @game.finished!
    end

    @game.broadcast_room_update(current_user)

    respond_to do |format|
      format.turbo_stream { head :ok }
      format.html { redirect_to @room }
    end
  end

  def destroy
    Turbo::StreamsChannel.broadcast_remove_to(
      "room_#{@room.id}",
      target: dom_id(@room)
    )

    @room.destroy

    respond_to do |format|
      format.turbo_stream { redirect_to rooms_path, status: :see_other }
      format.html { redirect_to rooms_path, notice: "Sala eliminada correctamente." }
    end
  end

  private

  def room_params
    params.require(:room).permit(:name, :status)
  end

  def set_room
    @room = Room.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to rooms_path, alert: "La sala ya no existe"
  end
end
