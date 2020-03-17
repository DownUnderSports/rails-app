# frozen_string_literal: true

require 'active_support/concern'
require 'active_record/associations'
require 'active_record/associations/builder/association'

module ActiveRecord
  module Associations
    module Builder
      class Association
        const_set(
          :VALID_OPTIONS,
          [ *(remove_const(:VALID_OPTIONS) || []), :primary_type ].freeze
        )
      end
    end
  end
end
