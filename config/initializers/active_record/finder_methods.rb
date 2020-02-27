require 'active_support'
require 'active_record'
require 'active_record/type'

ActiveSupport.on_load(:active_record) do
  module ActiveRecord
    module FinderMethods
      def get(*ids, &block)
        return ids.first if ids.first.is_a?(ApplicationRecord)

        return find(*ids, &block) if block_given?

        if (ids.size == 1) && (((id = ids.first.to_s) =~ /[A-Za-z]/) || ((@klass.name == "School") && (id.size > 11)))
          lookup_value(id)
        else
          find(*ids)
        end
      rescue RecordNotFound
      end

      def nth(idx)
        find_nth(idx - 1)
      end

      def nth!(idx)
        nth(idx) || raise_record_not_found_exception!
      end

      def nth_to_last(idx)
        find_nth_from_last(idx)
      end

      def nth_to_last!(idx)
        nth_to_last(idx) || raise_record_not_found_exception!
      end

      def find(*args)
        return super if block_given?
        find_with_ids(*args)
      rescue RecordNotFound
      end

      def find!(*args)
        find(*args) || raise_record_not_found_exception!
      end

      def find_by(opts, *rest)
        where(opts, *rest).take
      rescue ::RangeError
        nil
      end

      def find_by_dus_id_hash(hashed)
        find_by_hashed(:dus_id, hashed)
      end

      def find_by_hashed(col, hashed)
        where("#{col}_hash" => hashed).take
      end

      def lookup_value(id)
        if @klass.name == "Interest"
          @klass.get(id)
        elsif @klass.column_names.include?('pid')
          find_by(pid: id.to_s)
        elsif @klass.column_names.include?('dus_id')
          find_by(dus_id: id)
        elsif @klass.column_names.include?('abbr_gender')
          find_by(abbr_gender: id)
        elsif @klass.column_names.include?('abbr')
          find_by(abbr: id)
        elsif @klass.column_names.include?('code')
          find_by(code: id)
        elsif @klass.column_names.include?('pnr')
          find_by(pnr: id)
        else
          find(id)
        end
      end
    end
  end

  ActiveRecord::Querying.delegate :get, to: :all
  ActiveRecord::Querying.delegate :find_by_hashed, to: :all
  ActiveRecord::Querying.delegate :find_by_dus_id_hash, to: :all
end
