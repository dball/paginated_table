$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "paginated_table/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "paginated_table"
  s.version     = PaginatedTable::VERSION
  s.authors     = ["Donald Ball"]
  s.email       = ["donald.ball@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of PaginatedTable."
  s.description = "TODO: Description of PaginatedTable."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2"
  s.add_dependency "will_paginate", "~> 3.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "minitest"
  s.add_development_dependency "capybara"
  s.add_development_dependency "capybara-webkit"
end
