require 'coveralls/rake/task'

task :default => :test

Coveralls::RakeTask.new
task :test => [:spec, 'coveralls:push']
