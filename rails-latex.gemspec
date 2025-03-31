# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-latex/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-latex"
  spec.version       = RailsLatex::VERSION
  spec.authors       = ["Jan Baier", "Geoff Jacobsen"]
  spec.email         = ["jan.baier@amagical.net"]

  spec.summary       = %q{A LaTeX to PDF rails renderer.}
  spec.description   = %q{rails-latex is a renderer for rails which allows tex files with erb to be turned into an inline pdf.}
  spec.homepage      = "https://github.com/amagical-net/rails-latex"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'rails', '>= 3.0.0', '< 9'
  spec.add_development_dependency "RedCloth", "~> 4.3"
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13"
  spec.add_development_dependency "minitest", "~> 5.11"
  spec.add_development_dependency "minitest-reporters", "~> 1.3"
end
