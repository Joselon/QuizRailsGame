require "test_helper"

class RoomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
    @room = rooms(:one)
  end

  test "should get index" do
    get rooms_url
    assert_response :success
  end

  test "should get show" do
    get room_url(@room)
    assert_response :success
  end

  test "should get new" do
    get new_room_url
    assert_response :success
  end

  test "should create room" do
    assert_difference("Room.count") do
      post rooms_url, params: {
        room: { name: "Sala de prueba", status: :waiting, current_turn: 0 }
      }
    end

   assert_redirected_to room_url(Room.last)
  end

  test "should start room" do
    @room.update(status: :waiting)

    patch start_room_url(@room)
    assert_redirected_to room_url(@room)
    @room.reload
    assert_equal "playing", @room.status
  end

  test "should finish room" do
    @room.update(status: :playing)

    patch finish_room_url(@room)
    assert_redirected_to room_url(@room)
    @room.reload
    assert_equal "finished", @room.status
  end
end
