module CoreExtensions
  class BooleanTest < ActiveSupport::TestCase
    test ".parse returns true, false, or nil" do
      # explicitly check for true vs truthy
      assert_equal true, Boolean.parse(true)
      assert_equal true, Boolean.parse(1)
      assert_equal true, Boolean.parse("1")
      assert_equal true, Boolean.parse("t")
      assert_equal true, Boolean.parse("T")
      assert_equal true, Boolean.parse("true")
      assert_equal true, Boolean.parse("TRUE")
      assert_equal true, Boolean.parse("on")
      assert_equal true, Boolean.parse("ON")
      assert_equal true, Boolean.parse(" ")
      assert_equal true, Boolean.parse("\u3000\r\n")
      assert_equal true, Boolean.parse("\u0000")
      assert_equal true, Boolean.parse("SOMETHING RANDOM")
      assert_equal true, Boolean.parse(:"1")
      assert_equal true, Boolean.parse(:t)
      assert_equal true, Boolean.parse(:T)
      assert_equal true, Boolean.parse(:true)
      assert_equal true, Boolean.parse(:TRUE)
      assert_equal true, Boolean.parse(:on)
      assert_equal true, Boolean.parse(:ON)
      assert_equal true, Boolean.parse(Class)

      # explicitly check for false vs nil
      assert_predicate Boolean.parse(""), :nil?
      assert_predicate Boolean.parse(nil), :nil?
      assert_equal false, Boolean.parse(false)
      assert_equal false, Boolean.parse(0)
      assert_equal false, Boolean.parse("0")
      assert_equal false, Boolean.parse("f")
      assert_equal false, Boolean.parse("F")
      assert_equal false, Boolean.parse("false")
      assert_equal false, Boolean.parse("FALSE")
      assert_equal false, Boolean.parse("off")
      assert_equal false, Boolean.parse("OFF")
      assert_equal false, Boolean.parse(:"0")
      assert_equal false, Boolean.parse(:f)
      assert_equal false, Boolean.parse(:F)
      assert_equal false, Boolean.parse(:false)
      assert_equal false, Boolean.parse(:FALSE)
      assert_equal false, Boolean.parse(:off)
      assert_equal false, Boolean.parse(:OFF)
    end

    test ".strict_parse returns true or false" do
      # explicitly check for true vs truthy
      assert_equal true, Boolean.strict_parse(true)
      assert_equal true, Boolean.strict_parse(1)
      assert_equal true, Boolean.strict_parse("1")
      assert_equal true, Boolean.strict_parse("t")
      assert_equal true, Boolean.strict_parse("T")
      assert_equal true, Boolean.strict_parse("true")
      assert_equal true, Boolean.strict_parse("TRUE")
      assert_equal true, Boolean.strict_parse("on")
      assert_equal true, Boolean.strict_parse("ON")
      assert_equal true, Boolean.strict_parse(" ")
      assert_equal true, Boolean.strict_parse("\u3000\r\n")
      assert_equal true, Boolean.strict_parse("\u0000")
      assert_equal true, Boolean.strict_parse("SOMETHING RANDOM")
      assert_equal true, Boolean.strict_parse(:"1")
      assert_equal true, Boolean.strict_parse(:t)
      assert_equal true, Boolean.strict_parse(:T)
      assert_equal true, Boolean.strict_parse(:true)
      assert_equal true, Boolean.strict_parse(:TRUE)
      assert_equal true, Boolean.strict_parse(:on)
      assert_equal true, Boolean.strict_parse(:ON)

      # explicitly check for false vs nil
      refute_predicate Boolean.strict_parse(""), :nil?
      assert_equal false, Boolean.strict_parse("")
      refute_predicate Boolean.strict_parse(nil), :nil?
      assert_equal false, Boolean.strict_parse(nil)
      assert_equal false, Boolean.strict_parse(false)
      assert_equal false, Boolean.strict_parse(0)
      assert_equal false, Boolean.strict_parse("0")
      assert_equal false, Boolean.strict_parse("f")
      assert_equal false, Boolean.strict_parse("F")
      assert_equal false, Boolean.strict_parse("false")
      assert_equal false, Boolean.strict_parse("FALSE")
      assert_equal false, Boolean.strict_parse("off")
      assert_equal false, Boolean.strict_parse("OFF")
      assert_equal false, Boolean.strict_parse(:"0")
      assert_equal false, Boolean.strict_parse(:f)
      assert_equal false, Boolean.strict_parse(:F)
      assert_equal false, Boolean.strict_parse(:false)
      assert_equal false, Boolean.strict_parse(:FALSE)
      assert_equal false, Boolean.strict_parse(:off)
      assert_equal false, Boolean.strict_parse(:OFF)
    end
  end
end
