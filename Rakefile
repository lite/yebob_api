require 'rspec/core/rake_task'

desc 'Default: run specs.'
task :default => :spec

task :spec do
  desc "TDD"
  RSpec::Core::RakeTask.new do |t|
    #t.rspec_opts = %w{--colour --format progress --loadby mtime}
    t.pattern = "./spec/**/*_spec.rb"
  end

  desc "Generate code coverage"
  RSpec::Core::RakeTask.new(:coverage) do |t|
    t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
    t.rcov = true
    t.rcov_opts = ['--exclude', 'spec']
  end
end

