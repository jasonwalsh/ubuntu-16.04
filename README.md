> MongoDB Ubuntu 16.04 [Amazon Machine Image](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html) (AMI)

[![CircleCI](https://img.shields.io/circleci/build/github/jasonwalsh/ubuntu-16.04/master.svg?style=flat-square)](https://circleci.com/gh/jasonwalsh/ubuntu-16.04) [![GitHub release](https://img.shields.io/github/release/jasonwalsh/ubuntu-16.04.svg?style=flat-square)](https://github.com/jasonwalsh/ubuntu-16.04/releases/latest)

## Contents

- [Purpose](#purpose)
- [Requirements](#requirements)
- [Usage](#usage)
  - [AMI Lifecycle](#ami-lifecycle)
- [Examples](#examples)
- [License](#license)

## Purpose

The software automation ecosystem continues to grow and improve daily. Software like [Ansible](https://www.ansible.com/), [Chef](https://www.chef.io/), and [Puppet](https://puppet.com/) empowers developers to manage infrastructure lifecycles without human intervention. However, while automation does provide many benefits like mitigating human error, one of the most significant risks is compliance.

> **compliance** (noun): conformity in fulfilling official requirements

Infrastructure is much like software; it has requirements. For example, a web application server may require NGINX, whereas a machine learning environment may require Apache Spark. Requirements define the desired state of the infrastructure.

As infrastructure continues to increase in complexity, ensuring that requirements are satisfied imposes new challenges. For example, if a new release of NGINX is not backward compatible with an older version, then the web application described in the previous section may not be deployable. Therefore, ensuring the desired state of infrastructure is essential and guarantees correctness.


The purpose of this repository is to demonstrate managing the configuration code for provisioning and maintaining the lifecycle of an [Amazon Machine Image](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html) (AMI) using Ansible and InSpec.

## Requirements

- [Docker](https://www.docker.com/)

## Usage

The following environment variables are required to use this repository and are used by the [Docker Compose](docker-compose.yml) file.

| Name | Description |
|------|-------------|
| `AWS_ACCESS_KEY_ID` | Specifies an AWS access key associated with an IAM user or role |
| `AWS_SECRET_ACCESS_KEY` | Specifies the secret key associated with the access key |
| `AWS_DEFAULT_REGION` | Specifies the AWS Region to send the request to |

To learn more about Docker and Docker Compose, please visit [this](https://docs.docker.com/compose/overview/) documentation.

This repository uses [InSpec](https://www.inspec.io/), a platform-agnostic framework for ensuring the compliance of infrastructure.

The [`test`](test) directory contains InSpec tests that specify compliance requirements.

```
test
└── integration
    └── default
        ├── controls
        │   └── default.rb
        ├── default.yml
        ├── files
        │   └── packages.yml
        └── inspec.yml

4 directories, 4 files
```

The [`default.rb`](test/integration/default/controls/default.rb) file contains InSpec resources for determining compliance.

### AMI Lifecycle

The AMI lifecycle consists of three essential stages: `create`, `verify`, and `destroy`. The `create` stage is responsible for creating a new EC2 instance using the source AMI defined in the [kitchen.yml](kitchen.yml) configuration file. The `verify` stage is responsible for running compliance tests. The `destroy` stage is responsible for removing the EC2 instance.

> Why are these stages necessary?

Creating and destroying EC2 instances is time-consuming and results in slower feedback. Suppose that building a new Amazon Machine Images takes 30 minutes to complete. This process includes starting a new EC2 instance, waiting for SSH to become available, running any provisioning scripts, running compliance tests, and then destroying the instance. If the provisioning scripts run successfully, but the compliance tests fail, then nearly 30 minutes is wasted to receive feedback. Similar to writing software, building infrastructure requires the ability to make changes quickly and more frequently.

This repository uses [Kitchen](https://kitchen.ci/), an Infrastructure as Code (IaC) framework that manages the lifecycle of the resources that it creates.

This repository includes a Dockerfile and a Docker Compose file for making it easier to write and test changes to the Amazon Machine Image.

To run the entire Kitchen suite of commands, invoke the following command:

    $ docker-compose up

The previous command invokes the Kitchen [`test`](https://docs.chef.io/ctl_kitchen.html#kitchen-test) subcommand, which creates a new instance, runs the Ansible Playbook, runs the compliance tests, and then destroys the instance.

To invoke different subcommands, invoke the following command:

    $ docker-compose run --rm target COMMAND

Where `target` is the name of the Docker Compose [service](https://docs.docker.com/compose/compose-file/#service-configuration-reference), `--rm` removes the container after the subcommand finishes execution, and `COMMAND` is any of the subcommands defined in the [kitchen (executable)](https://docs.chef.io/ctl_kitchen.html) documentation.

## Examples

Suppose [Apache2 Web Server](https://help.ubuntu.com/lts/serverguide/httpd.html) is a required dependency for the Amazon Machine Image. Since having Apache2 installed is the *desired* state, then writing the InSpec test first is trivial.

Append the following InSpec code to the [`test/integration/default/controls/default.rb`](test/integration/default/controls/default.rb) file:

```ruby
describe package('apache2') do
  it { should be_installed }
end
```

After adding the InSpec code, invoke the following command:

    $ docker-compose run --rm target verify

The command above yields the following output:

```
Profile: Ubuntu 16.04 (ubuntu-16.04)
Version: 0.1.0
Target:  ssh://ubuntu@ec2-18-233-156-37.compute-1.amazonaws.com:22

  File /home/ubuntu/.bashrc
     ✔  should exist
  File /home/ubuntu/.bash_profile
     ✔  should exist
  Directory /etc/sudoers.d
     ✔  should exist
  System Package curl
     ✔  should be installed
  System Package g++
     ✔  should be installed
  System Package git
     ✔  should be installed
  System Package unzip
     ✔  should be installed
  System Package unattended-upgrades
     ✔  should not be installed
  Service apt-daily.service
     ✔  should not be running
  Service apt-daily.timer
     ✔  should not be running
  File /usr/local/bin/packer
     ✔  should exist
     ✔  should be executable
  System Package apache2
     ×  should be installed
     expected that `System Package apache2` is installed

Test Summary: 12 successful, 1 failure, 0 skipped
```

The InSpec tests fail because `apache2` is not installed. To resolve this issue, modify the Ansible task in the [`common`](roles/common) role to include `apache2` as a dependency to install via `apt`:

```yaml
- name: Install required packages
  apt:
    name:
      - apache2
      - g++
      - git
      - unzip
    state: present
    update_cache: false
  become: true
```

After updating the task, invoke the following commands:

    $ docker-compose run --rm target converge
    $ docker-compose run --rm target verify

After invoking the command above, the output should be as follows:

```
Profile: Ubuntu 16.04 (ubuntu-16.04)
Version: 0.1.0
Target:  ssh://ubuntu@ec2-18-233-156-37.compute-1.amazonaws.com:22

  File /home/ubuntu/.bashrc
     ✔  should exist
  File /home/ubuntu/.bash_profile
     ✔  should exist
  Directory /etc/sudoers.d
     ✔  should exist
  System Package curl
     ✔  should be installed
  System Package g++
     ✔  should be installed
  System Package git
     ✔  should be installed
  System Package unzip
     ✔  should be installed
  System Package unattended-upgrades
     ✔  should not be installed
  Service apt-daily.service
     ✔  should not be running
  Service apt-daily.timer
     ✔  should not be running
  File /usr/local/bin/packer
     ✔  should exist
     ✔  should be executable
  System Package apache2
     ✔  should be installed

Test Summary: 13 successful, 0 failures, 0 skipped
```

Notice that the previous commands do not destroy the EC2 instance. So if the image requires `nginx` instead of `apache2`, then the change can be easily made without having to wait for the EC2 instance to be created, provisioned, and destroyed.

This functionality is possible with Kitchen and provides great value for enabling faster feedback when making changes to infrastructure.

To list the instances managed via Kitchen and their last action, invoke the following command:

    $ docker-compose run --rm target list

```
Instance             Driver  Provisioner      Verifier  Transport  Last Action  Last Error
default-ubuntu-1604  Ec2     AnsiblePlaybook  Inspec    Ssh        Verified     <None>
```

## License

[MIT License](LICENSE)
