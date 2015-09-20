require_relative "api"

module VagrantPlugins
  module YarrsAndYamls
    class Plugin < Vagrant.plugin(2)
      class Command < Vagrant.plugin(2, :command)

        def synopsis
          "generates a starter Yarrs.yaml"
        end

        def execute
          create_vagrant_file
          create_yaml_file("Yarrs.yaml")

          @env.ui.success("yarrs-and-yamls: Successfully created Yarrs.yaml file!")
          @env.ui.success("yarrs-and-yamls: Next step - edit Yarrs.yaml then vagrant up")
          0
        end

        def create_vagrant_file
            source = File.expand_path('../../../Vagrantfile.example', __FILE__)
            dest = Dir.pwd + '/Vagrantfile'
            copy_file source, dest
        end

        def create_yaml_file(file)
            source = File.expand_path('../../../Yarrs.example.yaml', __FILE__)
            dest = Dir.pwd + "/#{file}"
            copy_file source, dest
        end

        def copy_file(source, dest)
            source = File.realpath(source)
            backup_file(dest)
            FileUtils.copy_file source, dest
        end

        def backup_file(source)
            dest = timestamp_filename(source)
            FileUtils.mv source, dest, :force => true if File.exists? source
        end

        def timestamp_filename(file)
            dir  = File.dirname(file)
            base = File.basename(file, ".*")
            time = Time.now.to_i
            ext  = File.extname(file)
            File.join(dir, "#{base}.bak.#{time}#{ext}")
        end
      end
    end
  end
end
