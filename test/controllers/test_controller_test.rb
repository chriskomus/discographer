require "test_helper"

class TestControllerTest < ActionDispatch::IntegrationTest
  test "should get index,add_want,edit_want,remove_want,whoami" do
    get test_index,add_want,edit_want,remove_want,whoami_url
    assert_response :success
  end
end
