module WithDataAttribute
  extend ActiveSupport::Concern

  class_methods do
    def data_column_attribute(attr, *opts, key: nil, **attribute_opts)
      attr = attr.to_sym
      key ||= attr
      key = key.to_s
      attribute attr, *opts, **attribute_opts
      include WithDataAttribute::InstanceMethodsOnActivation.new(attr, key)

      set_value = lambda do
        write_attribute(attr, data[key])
        data[key] = read_attribute(attr)
        data.delete(key) if data[key].nil?
        clear_attribute_change(attr) if persisted?
      end

      after_initialize &set_value
      after_commit &set_value
    end
  end

  class InstanceMethodsOnActivation < Module
    def initialize(attribute, key)
      define_method("data=") do |given|
        given = super((given || {}).with_indifferent_access)
        write_attribute(attribute, given[key])
        given[key] = read_attribute(attribute) unless read_attribute(attribute).nil?
        super(given)
      end

      define_method("#{attribute}=") do |given|
        super(given)
        data[key] = read_attribute(attribute)
        data.delete(key) if data[key].nil?
        write_attribute(:data, data)
        data[key]
      end
    end
  end
end
