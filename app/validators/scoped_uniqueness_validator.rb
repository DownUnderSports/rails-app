class ScopedUniquenessValidator < ActiveRecord::Validations::UniquenessValidator # :nodoc:
  def initialize(options)
    options[:attributes] = Array(options[:attributes]) | Array(options.delete(:scope))
    super
  end

  def validate(record)
    finder_class = find_finder_class_for(record)
    relations = attributes.map do |attribute|
      value = map_enum_attribute(
        finder_class,
        attribute,
        record.read_attribute_for_validation(attribute)
      ).presence
      build_relation(finder_class, attribute, value)
    end

    relation = relations.shift
    relations.each {|rel| relation.merge!(rel) }

    if record.persisted?
      if finder_class.primary_key
        relation = relation.where.not(finder_class.primary_key => record.id_in_database)
      else
        raise UnknownPrimaryKey.new(finder_class, "Cannot validate uniqueness for persisted record without primary key.")
      end
    end

    relation.merge!(options[:conditions]) if options[:conditions]

    if relation.exists?
      error_options = options.except(:case_sensitive, :scope, :conditions, :attribute)
      error_options[:message] ||= "#{options[:attribute] ? nil : "#{@klass} "}already exists"

      record.errors.add(options[:attribute] || :base, :taken, **error_options)
    end
  end

  module Concern
    extend ActiveSupport::Concern

    module ClassMethods
      def validates_uniqueness_of_scope(*attr_names)
        validates_with ScopedUniquenessValidator, _merge_attributes(attr_names)
      end
    end
  end
end
