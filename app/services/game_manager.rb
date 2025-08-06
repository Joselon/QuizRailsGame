class GameManager
  attr_reader :room

  def initialize(room)
    @room = room
    @dice_service = DiceRollService.new(room)
  end

  def self.for(room_or_id)
    room_id = room_or_id.is_a?(Room) ? room_or_id.id : room_or_id
    data = AppRedisClient.instance.redis.get(redis_key(room_id))
    data ? from_json(data) : new(Room.find(room_id))
  end

  def self.redis_key(room_id)
    "gamemanager:room:#{room_id}"
  end

  def self.from_json(json_data)
    data = JSON.parse(json_data)
    new(Room.find(data["room_id"]))
  end

  def save
    AppRedisClient.instance.redis.set(self.class.redis_key(@room.id), to_json)
  end

  def to_json(*_args)
    { room_id: @room.id }.to_json
  end

  def start_turn_order_phase!
    @room.update!(status: :rolling_for_order, current_turn: nil)
    @room.room_players.update_all(dice_roll: nil)
  end

  def start_tiebreak_phase!
    @room.update(status: :tiebreak_for_order)
    # TODO:clean dice rest of players
  end

  def roll_dice(user)
    player = @room.room_players.find_by(user:)
    raise "Player not found" unless player

    dice_value = @dice_service.roll_for(player)
    evaluate_rolls_and_update_state
    dice_value
  end

  def broadcast_room_update(user)
    Turbo::StreamsChannel.broadcast_replace_to(
      "room_#{@room.id}",
      target: "players",
      partial: "rooms/players_list",
      locals: { room: @room }
    )

    @room.room_players.each do |player|
      Turbo::StreamsChannel.broadcast_replace_to(
        player.user,
        target: "status-panel",
        partial: "rooms/status_panel",
        locals: { room: @room, room_player: player, current_user: player.user }
       )

      Turbo::StreamsChannel.broadcast_replace_to(
        player.user,
        target: "current_user_actions",
        partial: "rooms/current_user_actions",
        locals: { room: @room, room_player: player, current_user: player.user }
        )

      unless @room.playing?
        Turbo::StreamsChannel.broadcast_replace_to(
          player.user,
          target: "question-box",
          partial: "rooms/question_box",
          locals: { room: @room, room_player: player, current_user: player.user }
          )
      end
    end
  end

  def next_turn!
    players = @room.room_players.order(:turn_order)
    return if players.empty?

    current_index = players.find_index { |p| p.turn_order == @room.current_turn }
    next_index = current_index ? (current_index + 1) % players.size : 0

    @room.update(current_turn: players[next_index].turn_order)
  end

  def turn_order_decided?
    @room.room_players.all? { |p| p.dice_roll.present? } && @room.status != "tiebreak_for_order"
  end

  private

  def evaluate_rolls_and_update_state
    players = @room.room_players
    return unless players.all? { |p| p.dice_roll.present? }

    max_value = players.map(&:dice_roll).max
    top_players = players.select { |p| p.dice_roll == max_value }

    if top_players.size == 1
      @room.update!(current_turn: top_players.first.turn_order, status: :playing)
    else
      players.each { |p| p.update!(dice_roll: nil) }
      @room.update!(status: :tiebreak_for_order)
    end
  end
end
