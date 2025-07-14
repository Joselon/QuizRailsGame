class RoomPlayersController < ApplicationController
  before_action :authenticate_user!

  def join
    room = Room.find(params[:id])

    unless room.room_players.exists?(user_id: current_user)
      turn_order = room.room_players.count
      room.room_players.create(user: current_user, score: 0, turn_order: turn_order)
    end

    redirect_to room_path(room)
  end
end
