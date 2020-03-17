# frozen_string_literal: true
class Object
  def yes_no_to_s
    !!self == self ? ThreeState.titleize(self) : to_s
  end

  def y_n_to_s
    !!self == self ? ThreeState.convert_value(self) : to_s
  end
end
