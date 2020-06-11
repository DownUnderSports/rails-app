# encoding: utf-8
# frozen_string_literal: true

namespace :assets do
  desc 'fix no assets clean task without sprockets'
  task clean: :environment do
    Rake::Task["webpacker:clean"].invoke
  end
end
