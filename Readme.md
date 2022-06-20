EJBCA Packer template
=====================

Introduction
------------

This is a Hashicorp packer file to build an Alpine for VMWare

Setup
-----

1) Verify the template variables in the image-configs directory. Create a copy from the templates to your technology.

You can build them using command:
```
./build.sh <template name>
```

DANGER: 
Don't use the default .shvars-file, because it is just an example. It is better to reconfigure the file or use a Vault system to retrieve the credentials.

Usage
-----

It will show you the IP address it got from DHCP on the vmware console. You can ssh into the Alpine image using the ssh-keys generated in the secrets directory

TODO
----
- Add proxmox support

Notes
-----