> MongoDB Ubuntu 16.04 [Amazon Machine Image](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html) (AMI)

[![CircleCI](https://img.shields.io/circleci/build/github/jasonwalsh/ubuntu-16.04/master.svg?style=flat-square)](https://circleci.com/gh/jasonwalsh/ubuntu-16.04)

## Contents

- [Purpose](#purpose)
- [Requirements](#requirements)
- [Usage](#usage)
  - [AMI Lifecycle](#ami-lifecycle)
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

    $ docker-compose up

## License

[MIT License](LICENSE)
