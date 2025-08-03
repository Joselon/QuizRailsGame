class GameManager
  attr_reader :room

  def initialize(room)
    @room = room
    @dice_service = DiceRollService.new(room)
  end

  def self.for(room)
    data = AppRedisClient.instance.redis.get(redis_key(room.id))
    data ? from_json(data) : new(room)
  end

  def save
    AppRedisClient.instance.redis.set(self.class.redis_key(@room.id), Marshal.dump(self))
  end

  def self.redis_key(room_id)
    "gamemanager:room:#{room_id}"
  end

  def to_json
  {
    room_id: @room.id
  }.to_json
  end

  def self.from_json(json_data)
    data = JSON.parse(json_data)
    new(Room.find(data["room_id"]))
  end

  def start_turn_order_phase!
    @room.update(status: :rolling_for_order, current_turn: nil)
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
    check_dice_results
  end

  def broadcast_room_update(current_user)
    Turbo::StreamsChannel.broadcast_replace_to(
      "room_#{@room.id}",
      target: "players",
      partial: "rooms/players_list",
      locals: { room: @room, current_user: current_user }
    )

    Turbo::StreamsChannel.broadcast_replace_to(
      "room_#{@room.id}",
      target: "status-panel",
      partial: "rooms/status_panel",
      locals: { room: @room, current_user: current_user }
    )
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

  def check_dice_results
    players = @room.room_players
    return unless players.all? { |p| p.dice_roll.present? }

    max_value = players.map(&:dice_roll).max
    top_players = players.select { |p| p.dice_roll == max_value }

    if top_players.size == 1
      @room.update!(current_turn: top_players.first.turn_order, status: :playing)
    else
      (players - top_players).each { |p| p.update(dice_roll: nil) }
      @room.update!(status: :tiebreak_for_order)
    end
  end
end
