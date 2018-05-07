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

## Creating Amazon EC2 Machine Images (AMIs)
An AWS account is required in order to build AMIs with any of the example templates. All `amazon-ebs` builders are configured to launch t2.micro instances, which are included with the [free-tier](https://aws.amazon.com/free/).

You must decide how you are going to provide your AWS access keys to packer. [Read this page](https://www.packer.io/docs/builders/amazon.html#authentication) for more info. I recommend creating a credentials file, the default location Packer checks for this file is **$HOME/.aws/credentials** on Linux and macOS, or **%USERPROFILE%.aws\credentials** on Windows. To accociate your access keys with the default profile, include the lines below in your `credentials` file:

```
[default]
aws_access_key_id = YOUR ACCESS KEY
aws_secret_access_key = YOUR SECRET KEY

[default]
region = us-west-1
```

The `region` value should match the VPC that you wish to launch the EC2 instance and where the resulting AMI will be stored. The SDK checks the `AWS_PROFILE` environment variable to determine which profile to use. If no `AWS_PROFILE` variable is set, the SDK uses the default profile.

You can optionally specify a different location for Packer to look for the credentials file by setting the environment variable `AWS_SHARED_CREDENTIALS_FILE`. See [Amazon's documentation on specifying profiles](https://docs.aws.amazon.com/sdk-for-go/v1/developer-guide/configuring-sdk.html#specifying-profiles) for more details.

## Template Directory
* **nginx-ubuntu** (Ubuntu 16.04 with NGINX installed and configured)
* **wordpress-bedrock** ([Bedrock](https://github.com/roots/bedrock)-Wordpress running on Ubuntu 16.04 LEMP stack, fully configured and ready to install immediately)

## License
MIT License

## Author Information
Created in 2018 by [Aaron Luna](https://alunablog.com)
