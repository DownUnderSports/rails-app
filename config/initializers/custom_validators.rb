Rails.application.reloader.to_prepare do
  ActiveRecord::Base.include ScopedUniquenessValidator::Concern
end
