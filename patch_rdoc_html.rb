# frozen_string_literal: true

require "nokogiri"
require "fileutils"

DOC_DIR = "doc"
CSS_FILE = File.join(DOC_DIR, "css", "rdoc.css")

def process_html_files
  html_files = Dir.glob(File.join(DOC_DIR, "**", "*.html"))

  if html_files.empty?
    puts "No HTML files found in '#{DOC_DIR}/'."
    return
  end

  html_files.each do |file_path|
    html_content = File.read(file_path)
    doc = Nokogiri::HTML(html_content)
    modified = false

    # Find all .method-description blocks
    doc.css(".method-description").each do |desc|
      # Find direct <p> children whose text starts with ": ("
      rbs_ps = desc.xpath("./p").select do |p|
        p.text.lstrip.start_with?(": (")
      end

      next if rbs_ps.empty?

      modified = true

      rbs_ps.each do |p|
        # Strip the leading ": " from the first text node child
        p.children.first.content = p.children.first.content.sub(/^\s*:\s*/, "") if p.children.first&.text?

        # Add class="rbs-inline" safely (preserving existing classes if any)
        classes = p["class"].to_s.split
        classes << "rbs-inline"
        p["class"] = classes.uniq.join(" ")
      end

      # Move to the beginning of .method-description, preserving relative order
      # Reversing ensures that the first item ends up at the absolute top
      rbs_ps.reverse_each do |p|
        desc.prepend_child(p)
      end
    end

    # Write the changes back to the file if modifications occurred
    if modified
      File.write(file_path, doc.to_html)
      puts "Processed RBS signatures in: #{file_path}"
    end
  end
end

def append_custom_css
  unless File.exist?(CSS_FILE)
    puts "Warning: Could not find CSS file at #{CSS_FILE} to append styles."
    return
  end

  rbs_css_rule = <<~CSS

    /* Added by RBS inline post-processing script! */
    .method-description p.rbs-inline {
      font-family: var(--font-code);
      background-color: #f7f9fa;
      border-left: 3px solid #5b92e5;
      padding: 6px 10px;
      border-radius: var(--radius-sm);
      font-size: 0.9em;
      margin-top: 0;
    }
  CSS

  # Avoid duplicate appends if you run the script multiple times
  existing_css = File.read(CSS_FILE)
  if existing_css.include?("p.rbs-inline")
    puts "CSS rule already present in #{CSS_FILE}."
  else
    # Delete the file first to break the hard link to the gem directory!
    File.delete(CSS_FILE)
    File.write(CSS_FILE, existing_css + rbs_css_rule)
    puts "Appended .rbs-inline styles to #{CSS_FILE}"
  end
end

puts "Starting RDoc post-processing..."
process_html_files
append_custom_css
puts "Done!"
