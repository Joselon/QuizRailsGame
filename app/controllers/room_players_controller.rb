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
          target: "players",
           partial: "rooms/players_list",
          locals: { room: room, current_user: current_user }
    )

    Turbo::StreamsChannel.broadcast_replace_to(
          "room_#{room.id}",
          target: "current_user_actions",
           partial: "rooms/current_user_actions",
          locals: { room: room, current_user: current_user }
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

    @room = @room_player.room
    game = GameManager.for(@room)

    game.roll_dice(current_user)
    game.save
    game.evaluate_rolls_and_update_state
    game.broadcast_room_update(current_user)

    respond_to do |format|
      format.turbo_stream { head :ok }
      format.html { redirect_to game.room }
    end
  end

  private

  def set_room_player
    @room_player = RoomPlayer.find(params[:id])
  end
end
