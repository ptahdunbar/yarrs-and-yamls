# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-yamls-and-yarrs/version'

Gem::Specification.new do |spec|
    spec.name          = "vagrant-yamls-and-yarrs"
    spec.version       = VagrantPlugins::YarrsAndYamls::VERSION
    spec.authors       = ["Pirate Dunbar"]
    spec.email         = ["yarr@piratedunbar.com"]
    spec.description   = "Configure your Vagrantfile using YAML"
    spec.summary       = spec.description
    spec.homepage      = "https://github.com/ptahdunbar/yamls-and-yarrs"
    spec.license       = "GPL"
    #spec.post_install_message  = ""

    spec.files         = `git ls-files`.split($/)
    spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
    spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
    spec.require_paths = ["lib"]
end
