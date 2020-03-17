class ModelsByTable
  class << self
    def [](type)
      get(type)
    end

    def get(type, reset = false)
      models_index(reset)[type] ||= find_model_from_table_name(type)
    end

    def models_index(reset = false)
      @index_by_table_name = nil if reset

      @index_by_table_name ||= ActiveRecord::Base.descendants.reject(&:abstract_class).index_by(&:table_name)
    end

    def find_model_from_table_name(type)
      found_model = nil

      begin
        found_model = type.classify.constantize
        return found_model
      rescue
        found_model = nil
      end

      str =
        type.
          to_s.
          underscore.
          sub('.', '_').
          sub('public_', '')

      permeate_options(str).each do |sub_string|
        begin
          found_model = sub_string.classify.constantize
        rescue
          found_model = nil
        end
        break if found_model
      end

      raise "Model Not Found: #{type}" unless found_model

      found_model
    end

    def permeate_options(type)
      str = type.dup.sub(/^_+/, '').gsub(/_+/, '_')
      Enumerator.new do |y|
        if str =~ /_/
          split_str = str.split('_')

          underscores = str.gsub(/[^_]+/, '').split('')

          [*underscores, *Array.new(underscores.size, '/')].permutation(underscores.size).each do |mutation|
            y << split_str.zip(mutation).flatten.join
          end
        else
          y << str
        end
      end
    end
  end
end
