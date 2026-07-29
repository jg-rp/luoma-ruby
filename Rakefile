# frozen_string_literal: true

require "fileutils"
require "tmpdir"

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create

require "rubocop/rake_task"

RuboCop::RakeTask.new do |task|
  task.plugins << "rubocop-minitest"
  task.plugins << "rubocop-rake"
  task.plugins << "rubocop-performance"
end

require "steep/rake_task"

Steep::RakeTask.new do |t|
  t.check.severity_level = :error
  t.watch.verbose
end

namespace :docs do
  desc "Build the documentation using Zensical"
  task :build do
    puts "Building documentation with Zensical..."
    build_success = system("zensical build --clean")
    abort("Error: Failed to build documentation.") unless build_success
  end

  desc "Build and publish documentation to GitHub Pages"
  task deploy: :build do
    site_dir = "site"

    abort("Error: Output directory '#{site_dir}' missing. Build may have failed.") unless Dir.exist?(site_dir)

    # Retrieve the remote URL of your main Git repository
    remote = `git config --get remote.origin.url`.strip
    abort("Error: Could not determine Git remote URL for 'origin'.") if remote.empty?

    target_branch = "gh-pages"

    puts "Publishing '#{site_dir}' to #{target_branch} branch on #{remote}..."

    # Use a temporary directory to avoid touching local working tree state
    Dir.mktmpdir do |tmp_dir|
      # Copy all contents of the build folder into the temp directory
      FileUtils.cp_r(File.join(site_dir, "."), tmp_dir)

      # Initialize a temporary git repo and push to the remote branch
      Dir.chdir(tmp_dir) do
        system("git init -q")
        system("git checkout -b #{target_branch}")
        system("git add .")
        system("git commit -q -m 'Deploy documentation updates [skip ci]'")

        pushed = system("git push --force #{remote} #{target_branch}")
        abort("Error: Failed to push to GitHub Pages.") unless pushed
      end
    end

    puts "Successfully deployed documentation to GitHub Pages!"
  end
end

task default: %i[test rubocop steep]
