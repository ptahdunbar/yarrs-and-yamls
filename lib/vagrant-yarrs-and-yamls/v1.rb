
def yarrs_and_yamls(config=nil)
    raise 'Missing required parameter. yarrs_and_yamls(config)' if ! config

    vfile = VagrantPlugins::YarrsAndYamls::Plugin.get_config

    boxes = get_nodes(vfile)

    boxes.each do |hostname, box|
        config.vm.define hostname do |node|
            node.vm.box = box["box"]
            node.vm.box_url = box["box_url"]
            node.vm.box_check_update = box["box_check_update"]
            node.vm.boot_timeout = box["boot_timeout"]
            node.vm.box_download_checksum = box["box_download_checksum"]
            node.vm.box_download_checksum_type = box["box_download_checksum_type"]
            node.vm.box_download_client_cert = box["box_download_client_cert"]
            node.vm.box_download_ca_cert = box["box_download_ca_cert"]
            node.vm.box_download_ca_path = box["box_download_ca_path"]
            node.vm.box_download_insecure = box["box_download_insecure"]
            node.vm.box_version = box["box_version"]
            node.vm.communicator = box["communicator"]
            node.vm.graceful_halt_timeout = box["graceful_halt_timeout"]
            node.vm.guest = box["guest"]
            node.vm.post_up_message = box["post_up_message"]
            node.vm.usable_port_range = box["usable_port_range"]

            node.vm.network "private_network", ip: box["ip"], :netmask => "255.255.255.0" if box["ip"]

            if box["forwarded_ports"]
                box["forwarded_ports"].each do |port|
                    node.vm.network "forwarded_port", guest: port["guest"], host: port["host"]
                end
            end

            if box["synced_folders"]
                box["synced_folders"].each do |folder|
                    node.vm.synced_folder folder[:host], folder[:guest], folder[:args]
                end
            end

            if box["ssh"]
                node.ssh.username = box["ssh"]["username"] if box["ssh"]["username"]
                node.ssh.password = box["ssh"]["password"] if box["ssh"]["password"]
                node.ssh.host = box["ssh"]["host"] if box["ssh"]["host"]
                node.ssh.port = box["ssh"]["port"] if box["ssh"]["port"]
                node.ssh.guest_port = box["ssh"]["guest_port"] if box["ssh"]["guest_port"]
                node.ssh.private_key_path = box["ssh"]["private_key_path"] if box["ssh"]["private_key_path"]
                node.ssh.forward_agent = box["ssh"]["forward_agent"] if box["ssh"]["forward_agent"]
                node.ssh.forward_x11 = box["ssh"]["forward_x11"] if box["ssh"]["forward_x11"]
                node.ssh.insert_key = box["ssh"]["insert_key"] if box["ssh"]["insert_key"]
                node.ssh.proxy_command = box["ssh"]["proxy_command"] if box["ssh"]["proxy_command"]
                node.ssh.pty = box["ssh"]["pty"] if box["ssh"]["pty"]
                node.ssh.shell = box["ssh"]["shell"] if box["ssh"]["shell"]
            end

            if box["provision"]
                box["provision"].each do |script|
                    node.vm.provision "shell" do |s|
                        s.inline = script["inline"] if script["inline"]
                        s.path = script["path"] if script["path"]
                        s.args = script["args"] if script["args"]
                        s.privileged = script["privileged"] if script["privileged"]
                        s.binary = script["binary"] if script["binary"]
                        s.upload_path = script["upload_path"] if script["upload_path"]
                        s.keep_color = script["keep_color"] if script["keep_color"]
                        s.powershell_args = script["powershell_args"] if script["powershell_args"]
                    end
                end
            end

            node.vm.provider :virtualbox do |virtualbox, override|
                virtualbox.gui = true if box["gui"]
                virtualbox.cpus = box["cpus"] if box["cpus"]
                virtualbox.memory = box["memory"] if box["memory"]
            end

            node.vm.provider :vmware_fusion do |vmware, override|
                override.vm.node_url = "http://files.vagrantup.com/precise64_vmware.node"
                vmware.gui = true if box["gui"]
                vmware.vmx["numvcpus"] = box["cpus"] if box["cpus"]
                vmware.vmx["memsize"] = box["cpus"] if box["memory"]
            end

            node.vm.provider :aws do |aws, override|
                if box["aws"]
                    override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"

                    # Required parameters
                    aws.ami = box["aws"]["ami"] if box["aws"]["ami"]
                    aws.instance_type = box["aws"]["instance_type"] if box["aws"]["instance_type"]
                    aws.keypair_name = box["aws"]["keypair_name"] if box["aws"]["keypair_name"]
                    override.ssh.username = box["aws"]["username"] if box["aws"]["username"]
                    override.ssh.private_key_path = box["aws"]["private_key_path"] if box["aws"]["private_key_path"]

                    # Alternative approach: add keys into your .bashrc or .zshrc profile
                    # export AWS_SECRET_KEY=secret_key
                    # export AWS_ACCESS_KEY=secret_key
                    aws.access_key_id = box["aws"]["access_key_id"] || ENV["AWS_ACCESS_KEY"]
                    aws.secret_access_key = box["aws"]["secret_access_key"] || ENV["AWS_SECRET_KEY"]
                    aws.session_token = box["aws"]["session_token"] || ENV["AWS_SESSION_TOKEN"]

                    # optional settings
                    aws.region = box["aws"]["region"] if box["aws"]["region"]
                    aws.availability_zone = box["aws"]["availability_zone"] if box["aws"]["availability_zone"]
                    aws.security_groups = box["aws"]["security_groups"] if box["aws"]["security_groups"]
                    aws.tags = box["aws"]["tags"] if box["aws"]["tags"]
                    aws.subnet_id = box["aws"]["subnet_id"] if box["aws"]["subnet_id"]
                    aws.availability_zone = box["aws"]["availability_zone"] if box["aws"]["availability_zone"]
                    aws.elastic_ip = box["aws"]["elastic_ip"] if box["aws"]["elastic_ip"]
                    aws.use_iam_profile = box["aws"]["use_iam_profile"] if box["aws"]["use_iam_profile"]
                    aws.private_ip_address = box["aws"]["private_ip_address"] if box["aws"]["private_ip_address"]
                    aws.user_data = box["aws"]["user_data"] if box["aws"]["user_data"]
                    aws.iam_instance_profile_name = box["aws"]["iam_instance_profile_name"] if box["aws"]["iam_instance_profile_name"]
                    aws.iam_instance_profile_arn = box["aws"]["iam_instance_profile_arn"] if box["aws"]["iam_instance_profile_arn"]
                    aws.instance_package_timeout = box["aws"]["instance_package_timeout"] if box["aws"]["instance_package_timeout"]
                    aws.instance_ready_timeout = box["aws"]["instance_ready_timeout"] if box["aws"]["instance_ready_timeout"]
                end
            end

            node.vm.provider :digital_ocean do |digital_ocean, override|
                if box["digital_ocean"]
                    override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"

                    digital_ocean.token = box["digital_ocean"].include?("token") ? box["digital_ocean"]["token"] : ENV["DIGITAL_OCEAN_TOKEN"]

                    # Optional
                    override.ssh.private_key_path = box["digital_ocean"]["private_key_path"]
                    override.ssh.username = box["digital_ocean"]["username"] if box["digital_ocean"]["username"]
                    digital_ocean.ssh_key_name = box["digital_ocean"].include?("ssh_key_name") ? box["digital_ocean"]["ssh_key_name"] : 'Vagrant'
                    digital_ocean.image = box["digital_ocean"].include?("image") ? box["digital_ocean"]["image"] : "ubuntu-14-04-x64"
                    digital_ocean.region = box["digital_ocean"].include?("region") ? box["digital_ocean"]["region"] : "nyc2"
                    digital_ocean.size = box["digital_ocean"].include?("size") ? box["digital_ocean"]["size"] : "512mb"
                    digital_ocean.ipv6 = box["digital_ocean"].include?("ipv6") ? box["digital_ocean"]["ipv6"] : false
                    digital_ocean.private_networking = box["digital_ocean"].include?("private_networking") ? box["digital_ocean"]["private_networking"] : false
                    digital_ocean.backups_enabled = box["digital_ocean"].include?("backups_enabled") ? box["digital_ocean"]["backups_enabled"] : false
                    digital_ocean.setup = box["digital_ocean"].include?("setup") ? box["digital_ocean"]["setup"] : true
                end
            end
        end
    end

    config
end

def get_nodes(v=nil)
    boxes = {}

    return boxes if v["boxes"].empty?

    v["boxes"].collect do |box|
        next unless box["hostname"]

        boxes[box["hostname"]] = {}

        boxes[box["hostname"]]["box"] = v["box"] if v["box"]
        boxes[box["hostname"]]["box"] = box["box"] if box["box"]
        boxes[box["hostname"]]["box_check_update"] = box["box_check_update"] if box["box_check_update"]
        boxes[box["hostname"]]["box_url"] = box["box_url"]
        boxes[box["hostname"]]["box_check_update"] = box["box_check_update"]
        boxes[box["hostname"]]["boot_timeout"] = box["boot_timeout"]
        boxes[box["hostname"]]["box_download_checksum"] = box["box_download_checksum"]
        boxes[box["hostname"]]["box_download_checksum_type"] = box["box_download_checksum_type"]
        boxes[box["hostname"]]["box_download_client_cert"] = box["box_download_client_cert"]
        boxes[box["hostname"]]["box_download_ca_cert"] = box["box_download_ca_cert"]
        boxes[box["hostname"]]["box_download_ca_path"] = box["box_download_ca_path"]
        boxes[box["hostname"]]["box_download_insecure"] = box["box_download_insecure"]
        boxes[box["hostname"]]["box_version"] = box["box_version"]
        boxes[box["hostname"]]["communicator"] = box["communicator"]
        boxes[box["hostname"]]["graceful_halt_timeout"] = box["graceful_halt_timeout"]
        boxes[box["hostname"]]["guest"] = box["guest"]
        boxes[box["hostname"]]["post_up_message"] = box["post_up_message"]
        boxes[box["hostname"]]["usable_port_range"] = box["usable_port_range"]

        boxes[box["hostname"]]["ip"] = box["ip"] if box["ip"]

        if box["provision"]
            boxes[box["hostname"]]["provision"] ||= []
            box["provision"].each do |shell|
                boxes[box["hostname"]]["provision"].push(shell)
            end
        end

        if box["forwarded_ports"]
            boxes[box["hostname"]]["forwarded_ports"] ||= []
            box["forwarded_ports"].each do |item|
                next unless ( item.include?('host') or item.include?('guest') )
                boxes[box["hostname"]]["forwarded_ports"].push(item)
            end
        end

        box["synced_folders"] = box["shared_folders"] if box["shared_folders"]

        if box["synced_folders"]
            boxes[box["hostname"]]["synced_folders"] ||= []
            box["synced_folders"].each do |item|
                next unless ( item.include?('host') or item.include?('guest') )
                folder_args = item.dup
                folder_args.delete('host')
                folder_args.delete('guest')
                folder_args = Hash[folder_args.map{ |key, value| [key.to_sym, value] }]

                boxes[box["hostname"]]["synced_folders"].push({host: "#{item["host"]}", guest: "#{item["guest"]}", args: folder_args})
            end
        end

        if box["ssh"]
            boxes[box["hostname"]]["ssh"] ||= {}
            box["ssh"].each do |key, value|
                boxes[box["hostname"]]["ssh"][key] = value
            end
        end

        if box["disable_default_synced_folder"]
            boxes[box["hostname"]]["synced_folders"] ||= []
            boxes[box["hostname"]]["synced_folders"].push({ host:".", guest: "/vagrant", args: {id: "vagrant-root", disabled: true}})
        end

        box["memory"] = box["ram"] if box["ram"]
        boxes[box["hostname"]]["memory"] = box["memory"] if box["memory"]

        box["cpus"] = box["cpu"] if box["cpu"]
        boxes[box["hostname"]]["cpus"] = box["cpus"] if box["cpus"]

        boxes[box["hostname"]]["gui"] = box["gui"] if box["gui"]
        boxes[box["hostname"]]["disable_vm_optimization"] = box["disable_vm_optimization"] if box.include? "disable_vm_optimization"

        boxes[box["hostname"]]["aws"] = box["aws"] if box["aws"]
        boxes[box["hostname"]]["digital_ocean"] = box["digital_ocean"] if box["digital_ocean"]
    end

    boxes
end
