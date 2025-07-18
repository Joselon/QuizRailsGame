class RoomPlayersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room_player, only: [ :roll_dice ]

  def join
    room = Room.find(params[:id])

    unless room.room_players.exists?(user_id: current_user)
      turn_order = room.room_players.count
      room.room_players.create(user: current_user, score: 0, turn_order: turn_order)
    end

    redirect_to room_path(room)
  end

  def roll_dice
    DiceRollService.new(@room_player.room).roll_for(@room_player)
    respond_to do |format|
      format.js
      format.html { redirect_to @room_player.room }
    end
  end

  private

  def set_room_player
    @room_player = RoomPlayer.find(params[:id])
  end
end
