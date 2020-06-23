# encoding: utf-8
# frozen_string_literal: true

Rake::Task.define_task("assets:clean" => "webpacker:clean")
Rake::Task.define_task("assets:clobber" => "webpacker:clobber")
