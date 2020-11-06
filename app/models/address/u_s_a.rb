# encoding: utf-8
# frozen_string_literal: true

class Address < ApplicationRecord
  class USA < Structure
    # == Constants ============================================================

    # == Attributes ===========================================================

    # == Extensions ===========================================================

    # == Attachments ==========================================================

    # == Relationships ========================================================
    belongs_to :state, primary_key: :abbr, foreign_key: :region, optional: true

    # == Validations ==========================================================
    validates :city,
      presence: true

    validates :delivery,
      presence: true

    validates :postal_code,
      presence:   true,
      format:     {
                    with: /\A[0-9]{5}(-[0-9]{4})?\Z/,
                    message: "must be a valid US Zip Code"
                  }

    validate :region_is_a_state

    # == Scopes ===============================================================

    # == Callbacks ============================================================
    after_initialize :format_values
    before_validation :format_values

    # == Boolean Class Methods ================================================

    # == Class Methods ========================================================

    # == Boolean Methods ======================================================
    def invalid_region?
      (region !~ /\A[A-Z]{2}\Z/) \
      || !State.exists?(region)
    end

    # == Instance Methods =====================================================

    # == Private Methods ======================================================
    private
      def format_values
        self.postal_code = format_zip_code(postal_code)
        self.region = format_state(region)
      end

      def format_zip_code(value)
        return nil unless value.present?
        code, *other = value.to_s.split("-")
        four = +""
        other.each {|v| four << v.to_s if v.present? }
        code = code.rjust(5, "0") if code.present?
        code = "#{code}-#{four}" if four.present?
        code.presence
      end

      def format_state(value)
        return nil unless value.present?

        found = nil
        value = found.abbr if (value.to_s.size > 2) && (found = State.find_by(name: value))

        value.to_s.upcase.presence
      end

      def region_is_a_state
        errors.add(:region, "can't be blank") if region.blank?
        errors.add(:region, "must be a 2 letter US State") if invalid_region?
      end
  end
end
