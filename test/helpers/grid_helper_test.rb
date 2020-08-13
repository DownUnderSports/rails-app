require 'test_helper'

class GridHelperTest < ActionView::TestCase
  include GridHelper

  test "#cell_tag returns a content_tag with the given tag type" do
    %w[
      div
      section
      asdf
    ].each do |tag|
      assert_equal %Q(<#{tag} class="mdc-layout-grid__cell"></#{tag}>),
                   cell_tag(tag)
    end
  end

  test "#cell_tag includes passed classes" do
    assert_equal %Q(<div class="mdc-layout-grid__cell asdf"></div>),
                 cell_tag(class: "asdf")
  end

  test "#cell_tag sets spans for each given size properly" do
    assert_equal %Q(<div class="mdc-layout-grid__cell
                                mdc-layout-grid__cell--span-asdf
                                mdc-layout-grid__cell--span-2-phone
                                mdc-layout-grid__cell--span-1-largephone
                                mdc-layout-grid__cell--span-3-tablet
                                mdc-layout-grid__cell--span-4-desktop
                                mdc-layout-grid__cell--span-5-largedesktop"></div>).squish,
                 cell_tag(
                   base: "asdf",
                   phone: 2,
                   largephone: 1,
                   tablet: 3,
                   desktop: 4,
                   largedesktop: 5
                 )
  end

  test "#cell_tag sizes accept a hash" do
    assert_equal %Q(<div class="mdc-layout-grid__cell
                                mdc-layout-grid__cell--span-asdf
                                mdc-layout-grid__cell--order-asdf
                                mdc-layout-grid__cell--span-1-phone
                                mdc-layout-grid__cell--order-1-largephone"></div>).squish,
                 cell_tag(
                   base: { span: "asdf", order: "asdf" },
                   phone: { span: 1 },
                   largephone: { order: 1 },
                 )
  end

  test "#cell_tag :incremental accepts a size symbol" do
    assert_equal %Q(<div class="mdc-layout-grid__cell
                                mdc-layout-grid__cell--span-1
                                mdc-layout-grid__cell--span-3-phone
                                mdc-layout-grid__cell--span-2-tablet
                                mdc-layout-grid__cell--span-2-desktop
                                mdc-layout-grid__cell--span-2-largedesktop"></div>).squish,
                 cell_tag(
                   base: 1,
                   phone: 3,
                   tablet: 2,
                   incremental: :tablet
                 )
  end

  test "#cell_tag sets incremental sizes properly" do
    assert_equal %Q(<div class="mdc-layout-grid__cell
                                mdc-layout-grid__cell--span-asdf
                                mdc-layout-grid__cell--span-asdf-phone
                                mdc-layout-grid__cell--span-asdf-largephone
                                mdc-layout-grid__cell--span-2-tablet
                                mdc-layout-grid__cell--span-2-desktop
                                mdc-layout-grid__cell--span-5-largedesktop"></div>).squish,
                 cell_tag(
                   base: "asdf",
                   tablet: 2,
                   largedesktop: 5,
                   incremental: true
                 )

    assert_equal %Q(<div class="mdc-layout-grid__cell
                                mdc-layout-grid__cell--span-asdf
                                mdc-layout-grid__cell--order-asdf
                                mdc-layout-grid__cell--span-asdf-phone
                                mdc-layout-grid__cell--order-asdf-phone
                                mdc-layout-grid__cell--span-asdf-largephone
                                mdc-layout-grid__cell--order-asdf-largephone
                                mdc-layout-grid__cell--span-2-tablet
                                mdc-layout-grid__cell--order-asdf-tablet
                                mdc-layout-grid__cell--span-2-desktop
                                mdc-layout-grid__cell--order-asdf-desktop
                                mdc-layout-grid__cell--span-5-largedesktop
                                mdc-layout-grid__cell--order-1-largedesktop"></div>).squish,
                 cell_tag(
                   base: { span: "asdf", order: "asdf" },
                   tablet: 2,
                   largedesktop: { span: 5, order: 1 },
                   incremental: true
                 )
  end
end
