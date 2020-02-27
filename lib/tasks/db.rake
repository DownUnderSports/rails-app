# encoding: utf-8
# frozen_string_literal: true

namespace :db do
  desc 'Drop All Attachments'
  task drop_attachments: :environment do
    ActiveStorage::Blob.delete_all
    ActiveStorage::Attachment.delete_all
  end

  namespace :views do
    namespace :up do
      task before: :environment do
        require 'db/views'
        Views.before(false)
      end

      task after: :environment do
        require 'db/views'
        Views.after
      end
    end

    namespace :down do
      task before: :environment do
        require 'db/views'
        Views.before(true)
      end

      task after: :environment do
        require 'db/views'
        Views.after
      end
    end

    task rebuild: :environment do
      require 'db/views'
      Views.before(true)
      Views.after
    end
  end
end

Rake::Task['db:migrate'].enhance(['db:views:up:before', 'db:set_to_public']) do
  Rake::Task['db:set_to_default'].invoke
  Rake::Task['db:views:up:after'].invoke
end

Rake::Task['db:rollback'].enhance(['db:views:down:before', 'db:set_to_public']) do
  Rake::Task['db:set_to_default'].invoke
  Rake::Task['db:views:down:after'].invoke
end
