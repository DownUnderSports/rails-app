# encoding: utf-8
# frozen_string_literal: true

# Address description
class Address < ApplicationRecord
  # == Constants ============================================================

  # == Attributes ===========================================================
  # %w[
  #   postal_code
  #   region
  #   city
  #   delivery
  #   backup
  # ].each do |attr|
  #   p attr
  #   define_method "#{attr}=" do |v|
  #     p v
  #     structure.__send__("#{attr}=", v)
  #     super(structure.__send__(attr).presence)
  #   end
  # end

  # == Extensions ===========================================================

  # == Attachments ==========================================================

  # == Relationships ========================================================
  belongs_to :country,
    inverse_of: :addresses,
    optional:   true

  # == Validations ==========================================================
  after_initialize :get_structure
  validate :valid_for_country

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  # == Boolean Class Methods ================================================

  # == Class Methods ========================================================

  # == Boolean Methods ======================================================

  # == Instance Methods =====================================================
  def structure(refresh = false)
    @structure = nil if CoerceBoolean.from(refresh)

    return @structure if defined?(@structure) && @structure

    get_structure
  end

  # == Private Methods ======================================================
  private
    def get_structure
      model = ::Address.const_get(country&.alpha_3) rescue Address::Structure
      @structure = self.becomes(model)
    end

    def valid_for_country
      self.errors.merge!(structure.errors) unless structure.valid?
    end

end
