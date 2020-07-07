module TestHelper
  module DatabaseAssertions
    extend ActiveSupport::Concern

    def assert_database_not_null_constraint(klass, attribute, force: false)
      record = klass.new(attributes_without attribute)

      if force
        err = assert_nil_attr_raises(record, attribute)
      else
        err = assert_save_raises ActiveRecord::NotNullViolation, record
      end

      assert_match \
        "null value in column \"#{attribute}\" violates not-null constraint",
        err.message
    end

    def assert_database_unique_constraint(klass, index_name: nil, complex: nil, partial: nil, **duplicates)
      record    = klass.new(valid_attributes.merge(duplicates))
      err       = assert_save_raises ActiveRecord::RecordNotUnique, record
      partial   = partial && Array(partial).flatten.map(&:to_sym)

      if index_name
        assert_match \
          %r{duplicate key value violates unique constraint "?#{index_name}"?},
          err.message
      else
        assert_match \
          "duplicate key value violates unique constraint",
          err.message
      end

      if partial
        match = {}
        partial.map {|k| match[k] = duplicates[k] }
        duplicates = match
      end

      if complex
        duplicates.each do |k, v|
          assert_match \
            %r{DETAIL:\s+Key\s+\([^=]*"?#{k}"?[^=]*\)=\([^)]*"?#{v}"?[^)]*\)\s+already\s+exists\.},
            err.message
        end
      else
        assert_match \
          "DETAIL:  Key (#{duplicates.keys.join(", ")})=(#{duplicates.values.join(", ")}) already exists.",
          err.message
      end
    end

    def assert_save_raises(klass, record)
      assert_raises(klass) do
        record.save(validate: false)
      end
    end

    def assert_nil_attr_raises(record, attribute)
      assert_raises(ActiveRecord::NotNullViolation) do
        record.class.connection.transaction(requires_new: true) do
          if record.new_record?
            _raw_nil_insert record, attribute
          else
            _raw_nil_update record, attribute
          end
        end
      end
    end

    def _raw_nil_insert(row, attribute)
      attribute_names  = row.__send__ :attributes_for_create, row.attribute_names
      attribute_values = _get_attribute_values(row, attribute_names)

      attribute_values[attribute.to_s] = nil

      subbed  = _override_values(row.class, attribute_values, attribute)
      im      = row.class.arel_table.compile_insert(subbed)

      row.class.connection.insert(
        im,
        "#{row.class} Create",
        row.class.primary_key || false,
        nil
      )
    end

    def _raw_nil_update(row, attribute)
      attribute_names   = row.__send__ :attributes_for_update, row.attribute_names
      attribute_values  = _get_attribute_values(row, attribute_names)
      attribute_values[attribute.to_s] = nil

      pk          = row.instance_variable_get(:@primary_key)
      constraints = { pk => row.id_in_database }
      constraints = row.class.
                              __send__(:_substitute_values, constraints).
                              map { |attr, bind| attr.eq(bind) }

      subbed      = _override_values(row.class, attribute_values, attribute)
      um          = row.class.arel_table.
                                  where(constraints.reduce(&:and)).
                                  compile_update(subbed, row.class.primary_key)

      row.class.connection.update(um, "#{row.class} Update")
    end

    def _get_attribute_values(record, names)
      return {} if names.empty?
      record.
        __send__(:attributes_with_values, names - %w[ created_at updated_at ])
    end

    def _override_values(klass, values, attribute)
      values.map do |name, value|
        attr = klass.arel_attribute(name)
        if name == attribute.to_s
          bind = Arel::Nodes::BindParam.new(NilQueryAttribute.new(name.to_s))
        else
          bind = klass.predicate_builder.build_bind_attribute(name, value)
        end
        [attr, bind]
      end
    end

    class NilQueryAttribute < ActiveRecord::Relation::QueryAttribute
      def initialize(name)
        super(name, nil, ActiveModel::Type.default_value)
      end

      def type_cast(*) nil end
      def value_for_database; nil end
      def value_before_typecast; nil end
      def nil?; true end

      def with_cast_value(value)
        NilQueryAttribute.new(name, value, type)
      end

    end
  end
end
