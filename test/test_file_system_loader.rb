# frozen_string_literal: true

require "test_helper"

class TestFileSystemLoader < Minitest::Test
  make_my_diffs_pretty!

  def test_load_template
    loader = Luoma::FileSystemLoader.new(
      "test/fixtures/005/templates/"
    )
    env = Luoma::Environment.new(loader: loader)
    template = env.get_template("index.luoma")

    assert_instance_of(Luoma::Template, template)
    assert_equal("index.luoma", template.name)
  end

  def test_template_not_found
    loader = Luoma::FileSystemLoader.new(
      "test/fixtures/005/templates/"
    )
    env = Luoma::Environment.new(loader: loader)

    assert_raises(Luoma::TemplateNotFoundError) do
      env.get_template("nosuchthing.luoma")
    end
  end

  def test_no_such_search_path
    loader = Luoma::FileSystemLoader.new("no/such/thing")
    env = Luoma::Environment.new(loader: loader)

    assert_raises(Luoma::TemplateNotFoundError) do
      env.get_template("index.luoma")
    end
  end

  def test_array_of_paths_to_search
    loader = Luoma::FileSystemLoader.new(
      [
        "test/fixtures/002/templates/",
        "test/fixtures/005/templates/"
      ]
    )

    env = Luoma::Environment.new(loader: loader)
    # index.luoma from 005
    template = env.get_template("index.luoma")

    assert_instance_of(Luoma::Template, template)
    assert_equal("index.luoma", template.name)

    # header.luoma from 002
    template = env.get_template("header.luoma")

    assert_instance_of(Luoma::Template, template)
    assert_equal("header.luoma", template.name)
  end

  def test_default_file_extension_is_nil
    loader = Luoma::FileSystemLoader.new("test/fixtures/005/templates/")
    env = Luoma::Environment.new(loader: loader)

    assert_raises(Luoma::TemplateNotFoundError) do
      env.get_template("index")
    end
  end

  def test_set_default_file_extension
    loader = Luoma::FileSystemLoader.new(
      "test/fixtures/005/templates/",
      default_extension: ".luoma"
    )

    env = Luoma::Environment.new(loader: loader)
    template = env.get_template("index")

    assert_instance_of(Luoma::Template, template)
    assert_equal("index.luoma", template.name)
  end

  def test_stay_in_search_path
    loader = Luoma::FileSystemLoader.new("test/fixtures/005/templates/")
    env = Luoma::Environment.new(loader: loader)

    assert_raises(Luoma::TemplateNotFoundError) do
      env.get_template("../../002/templates/index.luoma")
    end
  end

  def test_templates_are_not_cached
    loader = Luoma::FileSystemLoader.new("test/fixtures/005/templates/")
    env = Luoma::Environment.new(loader: loader)
    template = env.get_template("index.luoma")

    assert_instance_of(Luoma::Template, template)
    assert_equal("index.luoma", template.name)
    assert_predicate(template, :up_to_date?)

    another_template = env.get_template("index.luoma")

    assert_equal("index.luoma", another_template.name)
    refute_same(template, another_template)
  end
end
