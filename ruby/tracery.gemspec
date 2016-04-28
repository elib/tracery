
file_list = Dir["lib/*.rb", "Rakefile"]
test_file_list = Dir["test/*.rb"]

require "./lib/version"

Gem::Specification.new do |s|
  s.name        = "tracery"
  s.version     = Tracery::VERSION
  s.date        = Date.today.to_s
  s.summary     = "A text expansion library"
  s.description = <<EOF
Tracery is a library for text generation.
The text is expanded by traversing a grammar.
Please see the Github repo for examples and documentation.
EOF
  s.authors     = ["Kate Compton", "Eli Brody"]
  s.email       = "brodyeli@gmail.com"
  s.files       = file_list
  s.test_files  = test_file_list
  s.homepage    = "https://github.com/elib/tracery"
  s.license     = "Apache-2.0"
end