require "vagrant"
require "yaml"
require_relative "v1"

module VagrantPlugins
    module YarrsAndYamls
        class Plugin < Vagrant.plugin(2)
            name "vagrant-yarrs-and-yamls"

            @@config = false

            action_hook(:init, :environment_unload) { maybe_create_yaml_file }
            action_hook(:load_config, Plugin::ALL_ACTIONS) { load_config }

            action_hook(:require_vagrant_plugins, :environment_load) {
                if ! self.get_config.empty?
                    self.require_vagrant_plugins(self.get_config["required_plugins"]) if self.get_config["required_plugins"]
                end
            }

            def self.maybe_create_yaml_file
                ARGV.each do |arg|
                    if arg.include?('init') || arg.include?('--yaml') || arg.include?('--yamls') || arg.include?('--yarrs')
                        self.create_vagrant_file
                        self.create_yaml_file
                    end
                end
            end

            def self.create_vagrant_file
                source = __FILE__ + '/../../../example.Vagrantfile'
                dest = Dir.pwd + '/Vagrantfile'
                self.copy_file source, dest
            end

            def self.create_yaml_file
                source = __FILE__ + '/../../../example.Vagrantfile.yml'
                dest = Dir.pwd + '/Vagrantfile.yml'
                self.copy_file source, dest
            end

            def self.copy_file(source, dest)
                source = File.realpath(source)
                self.backup_file(dest)
                FileUtils.copy_file source, dest
            end

            def self.backup_file(source)
                dest = self.timestamp_filename(source)
                FileUtils.mv source, dest, :force => true if File.exists? source
            end

            def self.timestamp_filename(file)
                dir  = File.dirname(file)
                base = File.basename(file, ".*")
                time = Time.now.to_i
                ext  = File.extname(file)
                File.join(dir, "#{base}.bak.#{time}#{ext}")
            end

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
