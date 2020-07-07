ActiveRecord::Type::Registration.class_eval do
  def <=>(other)
    if conflicts_with?(other)
      raise ActiveRecord::TypeConflictError.new("Type #{name} was registered for
                                  #{adapter || "all adapters"}, but shadows a
                                  native type with the same name for
                                  #{other.adapter}".squish)
    end
    priority <=> other.priority
  end

  protected

  def priority_except_adapter
    priority & ~1
  end
end
