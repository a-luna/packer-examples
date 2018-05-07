# Packer Examples
This repository contains a collection of example packer templates which create machime images running various applications. 

Each directory contains one or more JSON template files which can be built by running `packer build`. See the `README` file in each directory for any necessary steps that need to be performed before using the template.

## Install
1. [Install Packer](https://www.packer.io/intro/getting-started/install.html)
1. Open a new terminal and verify packer is available. Output should be similar to below:
```
$ packer
usage: packer [--version] [--help] <command> [<args>]

Available commands are:
    build       build image(s) from template
    fix         fixes templates from old versions of packer
    inspect     see components of a template
    push        push template files to a Packer build service
    validate    check that a template is valid
    version     Prints the Packer version
```

## Template Directory
* **nginx-ubuntu** (Ubuntu 16.04 with NGINX installed and configured)
* **wordpress-bedrock** ([Bedrock](https://github.com/roots/bedrock)-Wordpress running on Ubuntu 16.04 LEMP stack, fully configured and ready to install immediately)

## License
MIT License

## Author Information
Created in 2018 by [Aaron Luna](https://alunablog.com)
