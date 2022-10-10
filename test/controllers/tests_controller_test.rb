require "test_helper"

class TestsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get tests_index_url
    assert_response :success
  end

  test "should get add_want" do
    get tests_add_want_url
    assert_response :success
  end

  test "should get edit_want" do
    get tests_edit_want_url
    assert_response :success
  end

  test "should get remove_want" do
    get tests_remove_want_url
    assert_response :success
  end

  test "should get whoami" do
    get tests_whoami_url
    assert_response :success
  end
end
