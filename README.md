# Yarrs & Yamls

## Installation

`vagrant plugin install vagrant-yarrs-and-yamls`

Start a new vagrant project
`vagrant init`

Update an existing vagrant project
`vagrant --yamls`

Executing one of the above commands, your Vagrantfile should look like this now:
```
Vagrant.configure(2) do |config|
  # Advanced use:
  # yarrs('Yarrs.yaml', config) do |hostname, settings|
  # end

  # Regular use:
  yarrs('Yarrs.yaml', config)
end
```

Create a new file named `Yarrs.yaml`
```
# Yarrs.yaml accepts all values that normally go in Vagrantfile.
#
# For more information and examples, please see the online documentation at
# https://github.com/ptahdunbar/yarrs-and-yamls
---
boxes:
    - hostname: vagrant
      box: ubuntu/trusty64
      ip: "10.10.10.100"
      update: true
      nodejs: true
      php:
        - xdebug
        - composer
        - wp
      databases:
        - foo
        - bar
      synced_folders:
        - host: "."
          guest: "/var/www"
          # type: "nfs"
          owner: "www-data"
          group: "www-data"
          mount_options:
            - dmode=775
            - fmode=667
          rsync__args:
            - "--verbose"
            - "--archive"
            - "--delete"
            - "-z"
          rsync__exclude:
            - ".env.production"
            - ".env.production_network"
      provision:
        - path: provision/apache2.sh
      variables:
          - key: FOO
            value: bar
```

That's it! Boot up your environment:

```vagrant up```
