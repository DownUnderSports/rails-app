require "application_system_test_case"

module LayoutTests
  class TopBarTest < ApplicationSystemTestCase
    ELEMENT_CLICK_INTERCEPTED =
      Selenium::WebDriver::Error::ElementClickInterceptedError

    test "should exist" do
      visit root_url

      assert_has_top_bar
    end

    test "should be hidden behind app drawer scrim when open" do
      visit root_url

      assert_has_top_bar

      top_bar.click

      toggle_app_drawer

      assert top_bar.obscured?

      click_err =
        assert_raises(ELEMENT_CLICK_INTERCEPTED) do
          top_bar.click
        end

      regexp = %r{
        Element[ ]+<header[^>]+id="top-bar"[^>]+>\.\.\.</header>[ ]+is[ ]+not[ ]+clickable
        [ ]+at[ ]+point[ ]+\([0-9]+,[ ]+[0-9]+\)\.
        [ ]+Other[ ]+element[ ]+would[ ]+receive[ ]+the[ ]+click:
        [ ]+<[^>]+id="drawer-scrim"[^>]
      }x

      assert_match regexp, click_err.message

      toggle_app_drawer

      top_bar.click
    end

    test "should contain the app-drawer toggle" do
      visit root_url

      top_bar.assert_selector ".mdc-top-app-bar__section--align-end",
                              visible:  :visible,
                              count: 1,
                              class: %w[ mdc-top-app-bar__section ]

      wrapper = top_bar.find ".mdc-top-app-bar__section--align-end"

      wrapper.assert_selector "button#drawer-toggle-button",
                              visible: :visible,
                              count: 1,
                              class: %w[ mdc-top-app-bar__navigation-icon ],
                              text: "menu"
    end

  end
end
