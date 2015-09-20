require 'yaml'
require 'erb'

@template_path = File.expand_path('../../templates', __FILE__)
@scripts_path = File.expand_path('../../scripts', __FILE__)
@local_template_path = '/tmp/yarrs-and-yamls-templates'
@temp_path = '/etc/profile.d/vagrant.sh'
@profile = 'nginx'

def yarrs(yamlfile, vagrant_config)
    raise 'Missing required parameters, try: yarrs_and_yamls(\'Yarrs.yaml\', config)' if ! vagrant_config

    # load yaml config from file provided in Vagrantfile
    config = get_config_from_file(yamlfile)

    # convert single node to multi-node data structure
    config = { "nodes" => [config] } unless config.include?('nodes')

    # format nodes into instances
    instances = prepare(config)

    # loop through each instance and apply settings
    instances.each do |hostname, settings|

        vagrant_config.vm.define hostname do |node|

          apply_vagrant_settings(node, settings)
          apply_vagrant_ssh_settings(node, settings)
          apply_vagrant_shell_provisioning(node, settings)
          apply_vagrant_shared_folders(node, settings)
          apply_aws_provider(node, settings)
          apply_digitalocean_providier(node, settings)
          apply_local_scripts(node, settings)
          apply_vagrant_hostupdater(node, settings)

        end

        yield hostname, settings if block_given?
    end

    instances
end

def apply_vagrant_hostupdater(node, settings)
  if defined? VagrantPlugins::HostsUpdater && settings["hostname"] && settings["ip"]
    node.hostsupdater.aliases = get_config_part('sites', settings)
  end
end

def apply_vagrant_settings(node, settings)
  node.vm.box = settings["box"]
  node.vm.box_url = settings["box_url"]
  node.vm.box_check_update = settings["box_check_update"]
  node.vm.boot_timeout = settings["boot_timeout"]
  node.vm.graceful_halt_timeout = settings["graceful_halt_timeout"]
  node.vm.guest = settings["guest"]
  node.vm.post_up_message = settings["post_up_message"]
  node.vm.usable_port_range = settings["usable_port_range"]

  node.vm.provider :virtualbox do |virtualbox, override|
    virtualbox.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    virtualbox.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    virtualbox.customize ["modifyvm", :id, "--ostype", "Ubuntu_64"]
  end

  node.vm.provider :virtualbox do |virtualbox, override|
    virtualbox.gui = true if settings["gui"]
    virtualbox.cpus = settings["cpus"] if settings["cpus"]
    virtualbox.memory = settings["memory"] if settings["memory"]
  end

  ["vmware_fusion", "vmware_workstation"].each do |vmware|
    node.vm.provider vmware do |vmware, override|
      vmware.vmx["displayName"] = settings["hostname"]
      override.vm.node_url = "http://files.vagrantup.com/precise64_vmware.node"
      vmware.gui = true if settings["gui"]
      vmware.vmx["numvcpus"] = settings["cpus"] if settings["cpus"]
      vmware.vmx["memsize"] = settings["cpus"] if settings["memory"]
    end
  end

  node.vm.network "private_network", ip: settings["ip"], :netmask => "255.255.255.0" if settings["ip"]

  if settings["ports"]
      settings["ports"].each do |args|
        args = Hash[args.map{ |key, value| [key.to_sym, value] }]
        node.vm.network "forwarded_port", args
      end
  end

end

def apply_vagrant_ssh_settings(node, settings)
  node.ssh.username = settings["ssh_username"] if settings["ssh_username"]
  node.ssh.password = settings["ssh_password"] if settings["ssh_password"]
  node.ssh.host = settings["ssh_host"] if settings["ssh_host"]
  node.ssh.port = settings["ssh_port"] if settings["ssh_port"]
  node.ssh.guest_port = settings["ssh_guest_port"] if settings["ssh_guest_port"]
  node.ssh.private_key_path = settings["ssh_private_key_path"] if settings["ssh_private_key_path"]
  node.ssh.forward_agent = settings["ssh_forward_agent"] if settings["ssh_forward_agent"]
  node.ssh.forward_x11 = settings["ssh_forward_x11"] if settings["ssh_forward_x11"]
  node.ssh.insert_key = settings["ssh_insert_key"] if settings["ssh_insert_key"]
  node.ssh.proxy_command = settings["ssh_proxy_command"] if settings["ssh_proxy_command"]
  node.ssh.pty = settings["ssh_pty"] if settings["ssh_pty"]
  node.ssh.shell = settings["ssh_shell"] if settings["ssh_shell"]

  # Configure The Public Key For SSH Access
  if settings["authorize"]
    config.vm.provision "shell" do |s|
      s.inline = "echo $1 | grep -xq \"$1\" /home/vagrant/.ssh/authorized_keys || echo $1 | tee -a /home/vagrant/.ssh/authorized_keys"
      s.args = [File.read(File.expand_path(settings["authorize"]))]
    end
  end

  # Copy The SSH Private Keys To The Box
  if settings["keys"]
    settings["keys"].each do |key|
      config.vm.provision "shell" do |s|
        s.privileged = false
        s.inline = "echo \"$1\" > /home/vagrant/.ssh/$2 && chmod 600 /home/vagrant/.ssh/$2"
        s.args = [File.read(File.expand_path(key)), key.split('/').last]
      end
    end
  end
end

def apply_vagrant_shell_provisioning(node, settings)
  return unless settings["provision"]

  settings["provision"].each do |script|
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

def apply_vagrant_shared_folders(node, settings)
  return unless settings["synced_folders"]

  settings["synced_folders"].each do |item|
    next unless ( item.include?("host") or item.include?("guest") )
    args = item.dup
    args.delete('host')
    args.delete('guest')
    args = Hash[args.map{ |key, value| [key.to_sym, value] }]
    node.vm.synced_folder item["host"], item["guest"], args
  end
end

def apply_aws_provider(node, settings)
  return unless settings["aws"]
  node.vm.provider :aws do |aws, override|
    override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"

    # Required parameters
    aws.ami = settings["aws"]["ami"] if settings["aws"]["ami"]
    aws.instance_type = settings["aws"]["instance_type"] if settings["aws"]["instance_type"]
    aws.keypair_name = settings["aws"]["keypair_name"] if settings["aws"]["keypair_name"]
    override.ssh.username = settings["aws"]["username"] if settings["aws"]["username"]
    override.ssh.private_key_path = settings["aws"]["private_key_path"] if settings["aws"]["private_key_path"]

    # Alternative approach: add keys into your .bashrc or .zshrc profile
    # export AWS_SECRET_KEY=secret_key
    # export AWS_ACCESS_KEY=secret_key
    aws.access_key_id = settings["aws"]["access_key_id"] || ENV["AWS_ACCESS_KEY"]
    aws.secret_access_key = settings["aws"]["secret_access_key"] || ENV["AWS_SECRET_KEY"]
    aws.session_token = settings["aws"]["session_token"] || ENV["AWS_SESSION_TOKEN"]

    # optional settings
    aws.region = settings["aws"]["region"] if settings["aws"]["region"]
    aws.availability_zone = settings["aws"]["availability_zone"] if settings["aws"]["availability_zone"]
    aws.security_groups = settings["aws"]["security_groups"] if settings["aws"]["security_groups"]
    aws.tags = settings["aws"]["tags"] if settings["aws"]["tags"]
    aws.subnet_id = settings["aws"]["subnet_id"] if settings["aws"]["subnet_id"]
    aws.availability_zone = settings["aws"]["availability_zone"] if settings["aws"]["availability_zone"]
    aws.elastic_ip = settings["aws"]["elastic_ip"] if settings["aws"]["elastic_ip"]
    aws.use_iam_profile = settings["aws"]["use_iam_profile"] if settings["aws"]["use_iam_profile"]
    aws.private_ip_address = settings["aws"]["private_ip_address"] if settings["aws"]["private_ip_address"]
    aws.user_data = settings["aws"]["user_data"] if settings["aws"]["user_data"]
    aws.iam_instance_profile_name = settings["aws"]["iam_instance_profile_name"] if settings["aws"]["iam_instance_profile_name"]
    aws.iam_instance_profile_arn = settings["aws"]["iam_instance_profile_arn"] if settings["aws"]["iam_instance_profile_arn"]
    aws.instance_package_timeout = settings["aws"]["instance_package_timeout"] if settings["aws"]["instance_package_timeout"]
    aws.instance_ready_timeout = settings["aws"]["instance_ready_timeout"] if settings["aws"]["instance_ready_timeout"]
  end
end

def apply_digitalocean_providier(node, settings)
  return unless settings["digital_ocean"]

  node.vm.provider :digital_ocean do |digital_ocean, override|
    override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"

    digital_ocean.token = settings["digital_ocean"].include?("token") ? settings["digital_ocean"]["token"] : ENV["DIGITAL_OCEAN_TOKEN"]

    # Optional
    override.ssh.private_key_path = settings["digital_ocean"]["private_key_path"]
    override.ssh.username = settings["digital_ocean"]["username"] if settings["digital_ocean"]["username"]
    digital_ocean.ssh_key_name = settings["digital_ocean"].include?("ssh_key_name") ? settings["digital_ocean"]["ssh_key_name"] : 'Vagrant'
    digital_ocean.image = settings["digital_ocean"].include?("image") ? settings["digital_ocean"]["image"] : "ubuntu-14-04-x64"
    digital_ocean.region = settings["digital_ocean"].include?("region") ? settings["digital_ocean"]["region"] : "nyc2"
    digital_ocean.size = settings["digital_ocean"].include?("size") ? settings["digital_ocean"]["size"] : "512mb"
    digital_ocean.ipv6 = settings["digital_ocean"].include?("ipv6") ? settings["digital_ocean"]["ipv6"] : false
    digital_ocean.private_networking = settings["digital_ocean"].include?("private_networking") ? settings["digital_ocean"]["private_networking"] : false
    digital_ocean.backups_enabled = settings["digital_ocean"].include?("backups_enabled") ? settings["digital_ocean"]["backups_enabled"] : false
    digital_ocean.setup = settings["digital_ocean"].include?("setup") ? settings["digital_ocean"]["setup"] : true
  end
end

def get_config_from_file(configfile)

  config = {}

  return config unless configfile.index('.yaml')

  configfile = File.expand_path(configfile)
  localfile  = File.expand_path(configfile.dup)
  localfile  = localfile.insert(configfile.index('.yaml'), '.local')

  if File.exists? localfile
      config = YAML.load_file(localfile)
  elsif File.exists? configfile
      config = YAML.load_file(configfile)
  end

  config
end

def prepare(v=nil)
    boxes = {}

    return boxes if v["nodes"].empty?

    v["nodes"].collect do |box|
        next unless box["hostname"]
        boxes[box["hostname"]] = box
    end

    boxes
end

def apply_local_scripts(node, settings)
  node.vm.synced_folder @template_path, @local_template_path

  node.vm.provision "shell", inline: "touch #{@temp_path} && chmod +x #{@temp_path}"

  if settings["timezone"]
    node.vm.provision "shell" do |s|
      s.path = "#{@scripts_path}/tz.sh"
      s.args = [settings["timezone"]]
    end
  end

  if settings["update"]
    node.vm.provision "shell", path: "#{@scripts_path}/base.sh"
  end

  # if settings["rvm"]
  #   node.vm.provision "shell", path: "#{@scripts_path}/rvm.sh"
  # end

  if settings["git"]
    if File.exists? settings["git"].to_s
      gitconfig = settings["git"]
    else
      gitconfig = "#{@local_template_path}/gitconfig.conf"
    end

    node.vm.provision "shell" do |s|
      s.path = "#{@scripts_path}/git.sh"
      s.args = [gitconfig]
    end
  end

  if settings["mysql_root_password"]
    node.vm.provision "shell", inline: "echo export MYSQL_ROOT_PASSWORD=#{settings["mysql_root_password"]} >> #{@temp_path}"
  end

  if settings["databases"]
    node.vm.provision "shell", path: "#{@scripts_path}/mysql.sh"
    node.vm.provision "shell" do |s|
      s.path = "#{@scripts_path}/mysql-create-databases.sh"
      s.args = settings["databases"]
    end
  end

  if settings["variables"]
    settings["variables"].each do |pair|
      node.vm.provision "shell" do |s|
        s.path = "#{@scripts_path}/export_vars.sh"
        s.args = [ pair["key"], pair["value"] ]
      end
    end
  end

  if settings["nodejs"]
    node.vm.provision "shell", path: "#{@scripts_path}/nodejs.sh"

    if settings["nodejs"].kind_of?(Hash)
      settings["nodejs"].each do |key, value|
        if "global" == key
          node.vm.provision "shell" do |s|
            s.path = "#{@scripts_path}/install-nodejs-modules.sh"
            s.args = [value]
          end
        end
      end
    end
  end

  @profile = settings["webserver"] if settings["webserver"]
  @profile = settings["profile"] if settings["profile"]

  if File.exists?("#{@scripts_path}/#{@profile}.sh")
    node.vm.provision "shell", path: "#{@scripts_path}/#{@profile}.sh"
  end

  if settings["php"]
    node.vm.provision "shell", path: "#{@scripts_path}/php.sh"
    node.vm.provision "shell" do |s|
      s.path = "#{@scripts_path}/php_configure.sh"
      s.args = ["master"]
    end

    if settings["php"].include?('xdebug')
      xdebugconfig = "#{@local_template_path}/xdebug.ini"

      node.vm.provision "shell" do |s|
        s.path = "#{@scripts_path}/php_xdebug.sh"
        s.args = [xdebugconfig]
      end
    end

    node.vm.provision "shell", path: "#{@scripts_path}/composer.sh" if settings["php"].include?('composer')

    node.vm.provision "shell", path: "#{@scripts_path}/wpcli.sh" if settings["php"].include?('wp')
  end

  if settings["sites"]
    settings["sites"].each do |opts|
      opts = Hash[opts.map{ |key, value| [key.to_sym, value] }]
      @site = create_site(opts)

      next unless ! @site[:host].empty? && ! @site[:path].empty? && ! @site[:config].empty?

      backup_file = "#{Dir.pwd}/.#{@profile}-#{@site[:host]}.conf"
      File.open(backup_file, File::RDWR|File::CREAT) do |file|
        file.write(@site[:config].to_s)
      end

      node.vm.provision "shell" do |s|
        s.name = "nginx_site.sh: #{@site[:host]}, #{@site[:path]}"
        s.path = "#{@scripts_path}/nginx_site.sh"
        s.args = ["#{@site[:host]}", "#{@site[:path]}", "#{@site[:config]}"]
      end
    end
  end

  node.vm.provision "shell", inline: "rm -rf /etc/profile.d/vagrant.sh"

end

def get_config_part(key, config)
  result = nil

  if 'sites' == key && config.include?(key)
    sites = []

    config["sites"].each do |opts|
      opts = Hash[opts.map{ |key, value| [key.to_sym, value] }]
      site = create_site(opts)

      next unless ! site[:host].empty? && ! site[:path].empty? && ! site[:config].empty?

      sites.push(site[:host])
    end

    result = sites
  end

  result
end

def create_site(opts)
  site = {
    host: '',
    path: '',
    port: 80,
    ssl: false,
    template: "#{@template_path}/nginx_vhost.erb",
    config: '',
    vhost: '',
  }

  opts[:host] = opts[:map] || opts[:host]
  opts[:path] = opts[:to] || opts[:path]

  opts.each do |key, value|
    if !!key.to_s.index('.')
      site[:host] = key
    end
    if !!value.to_s.index('/')
      opts[:path] = value
    end
  end

  site.each do |key, val|
    if opts[key.to_sym]
      site[key.to_sym] = opts[key.to_sym]
    end
  end

  site[:config] = ERB.new(File.read(site[:template]))
  .result(OpenStruct.new(site).instance_eval { binding })

  site
end
