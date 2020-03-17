if Rails.const_defined? 'Console'
  class Integer
    def self.models
      @@record_models ||= Hash[*Dir[Rails.root.join('app', 'models', '**', '*.rb')].map do |file|
        @str_idx ||= Rails.root.join('app', 'models').to_s.size + 1
        str = file[@str_idx..-4]
        [str.gsub('/', '_'), str]
      end.flatten]
    end

    def self.add_lookup_method(method_name, klass)
      self.__send__ :define_method, method_name.to_sym do
        klass.find_by(id: self)
      end
    end


    def method_missing(method, *args)
      begin
        if m = is_model_lookup?(method)
          m = m.classify.constantize
          Integer.add_lookup_method method, m
          m.find_by((m.primary_key || :id) => self)
        else
          raise NoMethodError
        end
      rescue NoMethodError
        super(method, *args)
      end
    end

    private
      def is_model_lookup?(method = nil)
        (method.to_s =~ /^to\_[a-zA-Z\_0-9]+$/) &&
        (Integer.models[method.to_s.sub("to_", '')])
      end
  end
end
