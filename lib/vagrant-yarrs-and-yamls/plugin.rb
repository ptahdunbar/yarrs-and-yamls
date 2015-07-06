require "vagrant"
require "yaml"
require_relative "v1"

module VagrantPlugins
    module YarrsAndYamls
        class Plugin < Vagrant.plugin(2)
            name "vagrant-yarrs-and-yamls"

            @@config = false

            action_hook(:load_config, Plugin::ALL_ACTIONS) { load_config }

            action_hook(:require_vagrant_plugins, :environment_load) {
	            if ! self.get_config.empty?
                    self.require_vagrant_plugins(self.get_config["required_plugins"]) if self.get_config["required_plugins"]
                end
            }

            def self.load_config

                return @@config if @@config

				@@config = []
                configfile = ''

                # Try Vagrant.local.yml next
                if File.exists? "Vagrantfile.local.yml"
                    configfile = "Vagrantfile.local.yml"
                elsif File.exists? "Vagrantfile.yml"
                    configfile = "Vagrantfile.yml"
                end

                # pass in a configfile to load.
                ARGV.each do |arg|
                    if arg.include?('--config=')
                        configfile = arg.gsub('--config=', '')
                    end
                end

                #puts "configfile: #{configfile}"
                if File.exists? configfile
                    @@config = YAML.load_file(configfile);
                end
            end

            def self.get_config
                @@config
            end

            def self.require_vagrant_plugins(plugins)
                plugins.each do |plugin|
                    system "vagrant plugin install #{plugin}" unless Vagrant.has_plugin? plugin
                end
            end
        end
    end
end
