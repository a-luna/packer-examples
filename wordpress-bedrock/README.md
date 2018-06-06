# Packer Template: Bedrock-Wordpress running on LEMP Stack
This template installs and configures NGINX, PHP-FPM and MySQL on Ubuntu to host Wordpress as an all-in-one webserver/host. The template is currently configured to use Ubuntu 16.04 as the base image, however this can be changed to any other version available as a public AMI (Amazon EC2) or as an .iso file (VirtualBox).

Wordpress is installed using [Bedrock](https://github.com/roots/bedrock), which reorganizes the Wordpress code to allow greater security and dependancy management. [Composer](https://getcomposer.org) manages the Wordpress installation as well as the Themes and Plugins installed on the site. Since these are managed by Composer, the files can be ignored by your version control product, making the size of your repository much smaller and your website easier to maintain.

The Wordpress installation and webserver configuration are controlled entirely by the collection of user variables defined in the template file:

```JSON
"variables": {
  "nginx_ver": "1.13.12",
  "pcre_ver": "8.42",
  "zlib_ver": "1.2.11",
  "openssl_ver": "1.1.0h",
  "geoip_ver": "20180501",

  "mysql_root_temp_password": "w0rdPress5q!temp1",
  "wp_db_host": "localhost",
  "wp_db_name": "wordpress",
  "wp_db_user_name": "db_user",
  "wp_db_user_temp_password": "w0rdPress5q!temp2",

  "wp_host": "wp.bedrock",
  "wp_root_dir": "/sites",

  "working_dir": "/opt",
  "archive_folder": "archives",
  "deb_pkg_folder": "deb_pkg",
  "log_folder": "log",
  "service_config_folder": "service_config",
  "site_config_folder": "site_config",
  "site_files_folder": "site_files",
  "src_folder": "src_files",
  "log_file": "install_source.log"
  }
```

## License
MIT License

## Author Information
Created in 2018 by [Aaron Luna](https://alunablog.com)
