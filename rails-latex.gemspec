# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rails-latex/version"

Gem::Specification.new do |s|
  s.name        = "rails-latex"
  s.version     = Rails::Latex::VERSION
  s.authors     = ["Jan Baier", "Geoff Jacobsen"]
  s.email       = ["jan.baier@amagical.net"]
  s.homepage    = "https://github.com/baierjan/rails-latex"
  s.summary     = %q{A LaTeX to pdf rails 3 renderer.}
  s.description = %q{rails-latex is a renderer for rails 3 which allows tex files with erb to be turned into an inline pdf.}
  #s.licence     = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.rdoc_options = [%q{--main=README.rdoc}]

  s.extra_rdoc_files = [
    "MIT-LICENSE",
    "README.rdoc"
  ]

  s.add_dependency(%q<rails>, [">= 3.0.0"])
  s.add_development_dependency(%q<RedCloth>, [">= 4.2.7"])
end
