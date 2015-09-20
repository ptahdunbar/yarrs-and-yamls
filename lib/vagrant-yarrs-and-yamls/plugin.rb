require "vagrant"
require_relative "api"

module VagrantPlugins
    module YarrsAndYamls
        class Plugin < Vagrant.plugin(2)
            name "vagrant-yarrs-and-yamls"

            @@config = false

            action_hook(:init, :environment_unload) { maybe_create_yaml_file }
            # action_hook(:load_config, Plugin::ALL_ACTIONS) { load_config }

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
                source = __FILE__ + '/../../../Yarrs.example.yaml'
                dest = Dir.pwd + '/Yarrs.example.yaml'
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
        end
    end
end
