# GitHub Action: `packer-aws-ami`

The `packer-aws-ami` Action builds an AWS AMI from the provided inputs and packer template. Defaults to packer 1.7.

[![GitHub Action: Self-Test](https://github.com/craniumcafe/packer-aws-ami/actions/workflows/actions-self-test.yml/badge.svg?branch=main)](https://github.com/hashicorp/setup-packer/actions/workflows/actions-self-test.yml)

## Table of Contents

<!-- TOC -->
* [GitHub Action: `packer-aws-ami`](#github-action--packer-aws-ami)
  * [Table of Contents](#table-of-contents)
  * [Requirements](#requirements)
  * [Usage](#usage)
  * [Inputs](#inputs)
  * [Outputs](#outputs)
  * [Author Information](#author-information)
<!-- TOC -->

## Requirements

An AWS account and coresponding credentials.

## Usage

1.) Create an actions workflow (e.g.: `.github/workflows/build-ami.yml`):

```yaml
name: build-ami

on:
  push:

env:
  SUBNET_ID: "subnet-abcd1234"

jobs:
  build-ami:
    runs-on: ubuntu-latest
    name: Build AMI
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      
      - name: Test Action
        id: test-action
        uses: "./"
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: "us-west-2"
          build: "ubuntu-example"
          packer-directory: "./example"
          var-file: "./example/ubuntu-18.04.pkrvars.hcl"

      - name: Clean Up AMIs
        env:
          AMI_ID: ${{ steps.test-action.outputs.ami_id }}
        run: |
          aws ec2 deregister-image \
          --image-id $AMI_ID \
          --region us-west-2
```

## Inputs

This section lists available inputs.

### Required

The following inputs must be provided when calling the action.

* `aws-access-key-id` - The AWS access key to use to access the EC2 API.
* `aws-secret-access-key` - The AWS access key secret.
* `aws-region` - The AWS region to provision the instance in.
* `build` - The packer build name.

The following inputs must be provided as environment vairiables.

* `SUBNET_ID` - The VPC subnet to provision the instance into.

### Optional

The following are optional.

* `packer-directory` - The working directory for packer to execute in. Must contain the packer templates. Defaults to ./
* `packer-version` - The packer version. Defaults to 1.7
* `var-file` - The var file that provides build specific values. Defaults to none.

## Outputs

This section lists all outputs that can be consumed from this action.

* `ami-id` - The AWS AMI ID of the build artifact.
* `aws-region` - The AWS region where the resulting AMI is stored.

## Author Information

This GitHub Action is maintained by the contributors listed on [GitHub](https://github.com/craniumcafe/packer-ami-action/graphs/contributors).

The original code of this repository is based on [hashicorp/setup-packer](https://github.com/hashicorp/setup-packer) GitHub Action, and [chef-bento](https://github.com/chef/bento).
