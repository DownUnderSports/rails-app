# frozen_string_literal: true

class Integer
  def cents
    StoreAsInt.money(self)
  end

  def percent
    StoreAsInt.exchange_rate(self)
  end
end
