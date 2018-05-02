# Packer Example: Ubuntu 16.04 with Custom NGINX, Built from Source
This repo contains two packer template files which install the latest mainline NGINX from source on the most recent, official Ubuntu 16.04 AMI from Canonical. Provisioning is accomplished with bash scripts, and the NGINX configuration options can be modified to produce a custom install with any combination of builtin or third-party modules enabled.

## Requirements
You only need to have Packer installed on your system to use these examples. Please follow the simple instructions at the link below:

[Install Packer](https://www.packer.io/intro/getting-started/install.html)

## Usage
After installing Packer, clone this repo to your local system using the command below:

`git clone https://github.com/a-luna/packer-examples.git`

Make sure Packer is installed and navigate to the `packer-examples` directory in the terminal. 
