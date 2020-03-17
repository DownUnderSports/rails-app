require 'active_support'
require 'active_record'
require 'active_record/type'

ActiveSupport.on_load(:active_record) do
  module ActiveRecord
    module ConnectionAdapters
      class TableDefinition
        include ExchangeRateInteger::TableDefinition
        include Gender::TableDefinition
        include MoneyInteger::TableDefinition
        include ThreeState::TableDefinition
      end
    end
  end

  ActiveRecord::Type.register(:exchange_rate_integer, ExchangeRateInteger::Type)
  ActiveRecord::Type.register(:gender, Gender::Type)
  ActiveRecord::Type.register(:money_integer, MoneyInteger::Type)
  ActiveRecord::Type.register(:three_state, ThreeState::Type)
end
