# Yarrs And Yamls

## Installation

`vagrant plugin install vagrant-yarrs-and-yamls`

## Usage

Replace your Vagrantfile with:
```
Vagrant.configure(2) do |config|
    yarrs_and_yamls(config) do |hostname, settings|
        config.vm.define hostname do |node|
            #
            # Add your settings to Vagrantfile.yml
            #
        end
    end
end
```

Create a new file named `Vagrantfile.yml`

