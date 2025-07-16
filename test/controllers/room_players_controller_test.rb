require "test_helper"

class RoomPlayersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:two)
    sign_in @user
    @room = rooms(:one)
  end

  test "should join room" do
    assert_difference("RoomPlayer.count", 1) do
      post join_room_url(@room)
    end

    assert_redirected_to room_url(@room)
  end
end
