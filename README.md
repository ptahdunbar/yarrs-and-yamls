# Yarrs And Yamls

## Installation

`vagrant plugin install vagrant-yarrs-and-yamls`

## Usage

Start a new vagrant project
`vagrant init`

Update an existing vagrant project
`vagrant --yamls`

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
```
# Vagrantfile.yml accepts all values that normally go in Vagrantfile.
#
# For more information and examples, please see the online documentation at
# https://github.com/ptahdunbar/yarrs-and-yamls
---
boxes:
    - hostname: vagrant
      box: ubuntu/trusty64
```

That's it! Boot up your environment:

```vagrant up```
