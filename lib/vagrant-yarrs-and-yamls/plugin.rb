require "vagrant"
require_relative "api"

module VagrantPlugins
    module YarrsAndYamls
        class Plugin < Vagrant.plugin(2)
            name "vagrant-yarrs-and-yamls"

            command "yarrs" do
              require_relative "command"
              Command
            end
        end
    end
end
