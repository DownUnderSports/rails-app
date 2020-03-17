module CoreExtensions
  module AfterInitialized
    class TimeTest < ActiveSupport::TestCase
      test 'supports GlobalID' do
        assert_includes Time.included_modules, GlobalID::Identification
        assert_respond_to Time, :find
        assert_respond_to Time.new, :id
      end

      test '.find returns an ActiveSupport::TimeWithZone' do
        time = Time.new 2000,1,1,1,1,1
        int = time.to_i
        str = time.to_s
        assert_instance_of ActiveSupport::TimeWithZone, Time.find(int)
        assert_instance_of ActiveSupport::TimeWithZone, Time.find(str)
        assert_instance_of ActiveSupport::TimeWithZone, Time.find(time)
        assert_instance_of ActiveSupport::TimeWithZone, Time.find(Time.zone.now)
        assert_equal time, Time.find(int)
        assert_equal time, Time.find(str)
        assert_equal time, Time.find(time)
      end

      test '.find returns the given time in_time_zone when given a Time' do
        rounds = 0
        [
          [ Time, :new ],
          [ Time.zone, :local ]
        ].each do |klass, meth|
          rounds += 1

          called, args = nil
          test_time = klass.__send__ meth, 2000, 1, 1, 1, 1, 1

          was_called = ->(*called_with) do
            called = true
            args = called_with
            "WAS CALLED"
          end

          test_time.stub(:in_time_zone, was_called) do
            str = Time.zone.now.to_s
            refute_equal "WAS CALLED", Time.find(str)
            refute called
            assert_equal "WAS CALLED", Time.find(test_time)
          end

          assert called
          assert_equal test_time, Time.find(test_time)
          assert_equal [ ], args
        end

        assert_equal 2, rounds
      end

      test '.find returns a Time.zone.at when given an integer' do
        called, args = nil
        test_number = 3660
        was_called = ->(*called_with) do
          called = true
          args = called_with
          "WAS CALLED"
        end
        Time.zone.stub(:at, was_called) do
          str = Time.zone.now.to_s
          refute_equal "WAS CALLED", Time.find(str)
          refute called
          assert_equal "WAS CALLED", Time.find(test_number)
        end
        assert called
        assert_equal [ test_number ], args
      end

      test '.find returns Time.zone.parse when not given an integer' do
        called, args = nil
        test_string = "2020-01-01 1:00"
        was_called = ->(*called_with) do
          called = true
          args = called_with
          "WAS CALLED"
        end
        Time.zone.stub(:parse, was_called) do
          refute_equal "WAS CALLED", Time.find(0)
          refute called
          assert_equal "WAS CALLED", Time.find(test_string)
        end
        assert called
        assert_equal [ test_string ], args
      end

      test '#id is an alias for #iso8601' do
        sample = Time.new

        assert_equal sample.iso8601, sample.id
        assert_alias_of sample, :iso8601, :id
      end
    end
  end
end
