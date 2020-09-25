module ActiveRecordPersisitenceOverrides
  warn "[DEPRECATED] #{self} should no longer be needed. Please remove!" if Rails.version >= "6.0.3.4"

  def self.prepended(base)
    base.class_eval do
      def becomes(klass)
        became = klass.allocate

        became.send(:initialize) do |becoming|
          becoming.instance_variable_set(:@attributes, @attributes)
          becoming.instance_variable_set(:@mutations_from_database, @mutations_from_database ||= nil)
          becoming.instance_variable_set(:@new_record, new_record?)
          becoming.instance_variable_set(:@destroyed, destroyed?)
          becoming.errors.copy!(errors)
        end

        became
      end
    end
  end
end

ActiveRecord::Persistence.prepend ActiveRecordPersisitenceOverrides
