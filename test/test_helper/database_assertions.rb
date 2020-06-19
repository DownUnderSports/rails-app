module TestHelper
  module DatabaseAssertions
    extend ActiveSupport::Concern

    def assert_save_raises(klass, record)
      err = assert_raises(klass) do
        record.save(validate: false)
      end

      err
    end

    def assert_database_not_null_constraint(klass, attribute)
      record = klass.new(attributes_without attribute)

      err = assert_save_raises ActiveRecord::NotNullViolation, record

      assert_match \
        "null value in column \"#{attribute}\" violates not-null constraint",
        err.message
    end

    def assert_database_unique_constraint(klass, attribute, duplicate)
      record    = klass.new(valid_attributes.merge(attribute => duplicate))
      err       = assert_save_raises ActiveRecord::RecordNotUnique, record

      assert_match \
        "duplicate key value violates unique constraint",
        err.message

      assert_match \
        "DETAIL:  Key (#{attribute})=(#{duplicate}) already exists.",
        err.message
    end
  end
end
