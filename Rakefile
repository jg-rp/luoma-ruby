# frozen_string_literal: true

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

desc "Generate RDoc documentation and post-process inline RBS comments"
task :docs do
  puts "Clearing ./doc..."
  rm_rf "./doc"
  puts "Generating RDoc..."
  sh "bundle exec rdoc"
  sh "bundle exec ruby patch_rdoc_html.rb"

  puts "Generating SEO & deployment optimization files..."

  site_url = "https://jg-rp.github.io/luoma-ruby"
  doc_dir = "doc"
  html_files = Dir.glob(File.join(doc_dir, "**", "*.html"))

  # Prevent GitHub Pages from running Jekyll
  File.write(File.join(doc_dir, ".nojekyll"), "")

  # Public robots.txt pointing to our future sitemap
  robots_content = <<~TXT
    User-agent: *
    Allow: /

    Sitemap: #{site_url}/sitemap.xml
  TXT
  File.write(File.join(doc_dir, "robots.txt"), robots_content)

  # Friendly 404 Page
  error_page_content = <<~HTML
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <title>Page Not Found</title>
      <style>
        body { font-family: sans-serif; text-align: center; padding: 50px; color: #333; }
        a { color: #5b92e5; text-decoration: none; }
        a:hover { text-decoration: underline; }
      </style>
    </head>
    <body>
      <h1>Documentation Page Not Found</h1>
      <p>The class or method you are looking for may have been renamed or refactored.</p>
      <p><a href="./index.html">← Return to the Documentation Index</a></p>
    </body>
    </html>
  HTML
  File.write(File.join(doc_dir, "404.html"), error_page_content)

  # Dynamically build sitemap.xml from the actual generated files
  sitemap_urls = html_files.map do |path|
    # Convert local path "doc/MyClass.html" to web URL "https://.../MyClass.html"
    relative_path = path.sub(/^doc\//, "")
    "  <url><loc>#{site_url}/#{relative_path}</loc></url>"
  end

  sitemap_content = <<~XML
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    #{sitemap_urls.join("\n")}
    </urlset>
  XML
  File.write(File.join(doc_dir, "sitemap.xml"), sitemap_content)

  puts "Done! Built, patched, and SEO-optimized for public deployment."
end

desc "Generate, patch, and deploy documentation to GitHub Pages"
task deploy: :docs do
  puts "Preparing to deploy to GitHub Pages..."

  # Fetch the remote origin URL dynamically so this script is highly portable
  remote_url = `git remote get-url origin`.strip
  abort "Error: Could not determine Git remote 'origin' URL." if remote_url.empty?

  # Navigate into the doc directory to run git commands in isolation
  Dir.chdir("doc") do
    # Initialize a dummy repository inside the untracked doc folder
    sh "git init"
    sh "git add ."
    sh "git commit -m 'Deploy RDoc update via Rake'"

    puts "Force-pushing to the gh-pages branch..."
    # Force push the local 'main/master' of this sub-repo to the remote gh-pages branch
    sh "git push --force #{remote_url} HEAD:gh-pages"

    # Clean up the local dummy .git folder so it doesn't mess with your main project
    rm_rf ".git"
  end

  puts "Deployment triggered successfully! Give GitHub Pages a minute to process."
end

task default: %i[test rubocop steep]
