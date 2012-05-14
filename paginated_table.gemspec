$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "paginated_table/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "paginated_table"
  s.version     = PaginatedTable::VERSION
  s.authors     = ["Donald Ball"]
  s.email       = ["donald.ball@gmail.com"]
  s.homepage    = "http://github.com/dball/paginated_table"
  s.summary     = "Easy paginated, sorted tables in rails"
  s.description = "Provides AJAX paginated, sorted tables in rails with will_paginate and arel"

  s.files = [
    'lib/paginated_table.rb',
    'lib/paginated_table/column_description.rb',
    'lib/paginated_table/config.rb',
    'lib/paginated_table/controller_helpers.rb',
    'lib/paginated_table/data_page.rb',
    'lib/paginated_table/engine.rb',
    'lib/paginated_table/link_renderer.rb',
    'lib/paginated_table/page.rb',
    'lib/paginated_table/page_params.rb',
    'lib/paginated_table/railtie.rb',
    'lib/paginated_table/row_description.rb',
    'lib/paginated_table/table_description.rb',
    'lib/paginated_table/table_renderer.rb',
    'lib/paginated_table/version.rb',
    'lib/paginated_table/view_helpers.rb',
    'vendor/assets/javascripts/paginated_table.js'
  ]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2"
  s.add_dependency "will_paginate", "~> 3.0"
  s.add_dependency "jquery-rails", "~> 2.0"

  s.add_development_dependency "minitest"
  s.add_development_dependency "capybara"
  s.add_development_dependency "capybara-webkit"
  s.add_development_dependency "mocha"
end
