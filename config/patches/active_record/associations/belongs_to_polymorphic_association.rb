# frozen_string_literal: true

require 'active_support/concern'
require 'active_record/associations'
require 'active_record/associations/belongs_to_polymorphic_association'

module ActiveRecord
  module Associations
    # = Active Record Belongs To Polymorphic Association
    class BelongsToPolymorphicAssociation < BelongsToAssociation
      def klass
        type = owner[reflection.foreign_type]
        type.presence &&
          ModelsByTable.get(type)
      end

      def replace_keys record
        super
        owner[reflection.foreign_type] = record ? get_type_value(record) : nil
      end

      def get_type_value record
        Auditing::PolymorphicOverride.polymorphic_value(record.class, reflection.options)
      end
    end
  end
end
