class RoomPlayersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room_player, only: [ :roll_dice ]

  def join
    room = Room.find(params[:id])

    unless room.room_players.exists?(user_id: current_user)
      turn_order = room.room_players.count
      room.room_players.create(user: current_user, score: 0, turn_order: turn_order)
    end

    Turbo::StreamsChannel.broadcast_replace_to(
          "room_#{room.id}",
          target: "players-list",
           partial: "rooms/players_list",
          locals: { room: room }
    )

    respond_to do |format|
      format.html { redirect_to room_path(room) }
      format.turbo_stream { head :ok }
    end
  end

  def roll_dice
    unless @room_player.user == current_user
      head :forbidden and return
    end

    DiceRollService.new(@room_player.room).roll_for(@room_player)

    Turbo::StreamsChannel.broadcast_replace_to(
      "room_#{@room_player.room.id}",
      target: "players",
      partial: "rooms/players_list",
      locals: { room: @room_player.room }
    )

    respond_to do |format|
      format.js
      format.html { redirect_to @room_player.room }
      format.turbo_stream { head :ok }
    end
  end

  private

  def set_room_player
    @room_player = RoomPlayer.find(params[:id])
  end
end
