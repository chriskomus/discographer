require "application_system_test_case"

class ReleasesTest < ApplicationSystemTestCase
  setup do
    @release = releases(:one)
  end

  test "visiting the index" do
    visit releases_url
    assert_selector "h1", text: "Releases"
  end

  test "should create release" do
    visit releases_url
    click_on "New release"

    click_on "Create Release"

    assert_text "Release was successfully created"
    click_on "Back"
  end

  test "should update Release" do
    visit release_url(@release)
    click_on "Edit this release", match: :first

    click_on "Update Release"

    assert_text "Release was successfully updated"
    click_on "Back"
  end

  test "should destroy Release" do
    visit release_url(@release)
    click_on "Destroy this release", match: :first

    assert_text "Release was successfully destroyed"
  end
end
