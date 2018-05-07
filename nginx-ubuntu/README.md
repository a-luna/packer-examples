# Packer Example: Ubuntu 16.04 with Custom NGINX Built from Source
This repo contains two packer template files which install the latest mainline release of NGINX from source on the most recent, official Ubuntu 16.04 AMI from Canonical. Provisioning is performed with shell scripts, and the NGINX configuration options can be modified to produce a custom install with any combination of builtin or third-party modules enabled.

[Click here for a complete guide to using these packer templetes.](https://alunablog.com/2018/03/30/packer-template-aws-ec2-ubuntu-nginx/)

### nginx_ubuntu_from_source.json
You must build this packer template first, since the other template, `nginx_ubuntu_from_deb.json`, installs NGINX from a .deb file which is created from this template.

If your AWS account has a default VPC setup, you can remove the three lines below from the template file (lines 32-34) and packer will launch the EC2 instance within your default VPC. If you do not have a default VPC setup or you wish to launch the EC2 instance in a different VPC, you must provide values for `vpc_id` and `subnet_id`  before you can use the template:

```JSON
"vpc_id": "vpc-xxxxxxxx",
"subnet_id": "subnet-xxxxxxxx",
"associate_public_ip_address": "true"
```

If using a non-default VPC, public IP addresses are not provided by default. If `associate_public_ip_address` is set to `true`, your new instance will get a Public IP.

Make sure Packer is installed and navigate to the `nginx-ubuntu` directory. Validate the changes you made to the template file by running `packer validate`. If the template is not valid, any errors will be output to the console. The template will be validated if your changes were made correctly:

```
packer-examples $ packer validate nginx_ubuntu_from_deb.json
                  Template validated successfully.
```

To build the AMI, run:

```
packer-examples $ | packer build nginx_ubuntu_from_deb.json
```

You will see a lot of output to the console while packer is creating the AMI, please [see this article for full details of the build automation process](https://alunablog.com/2018/03/30/packer-template-aws-ec2-ubuntu-nginx/).

After a few minutes, Packer should tell you that an AMI with your customized NGINX installation was generated successfully:

```
==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs: AMIs were created:
us-west-1: ami-xxxxxxxx
```

You can launch an instance of this AMI from the AWS Console. NGINX will be configured and running, you can verify by running the command below:

```
$ sudo systemctl status nginx.service
  ● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/etc/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: active (running) since Sun 2018-04-29 07:55:18 UTC; 18s ago
    Process: 1164 ExecStart=/usr/sbin/nginx -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
    Process: 1124 ExecStartPre=/usr/sbin/nginx -t -q -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
   Main PID: 1171 (nginx)
      Tasks: 2
     Memory: 4.7M
        CPU: 9ms
     CGroup: /system.slice/nginx.service
             ├─1171 nginx: master process /usr/sbin/nginx -g daemon on; master_process on
             └─1174 nginx: worker process
             
  Apr 29 07:55:18 ip-172-31-12-194 systemd[1]: Starting A high performance web server and a reverse proxy server...
  Apr 29 07:55:18 ip-172-31-12-194 systemd[1]: Started A high performance web server and a reverse proxy server.
```
