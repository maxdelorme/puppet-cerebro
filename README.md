# Cerebro
[![Puppet Forge](https://img.shields.io/puppetforge/v/mrwulf/cerebro.svg?style=flat-square)](https://forge.puppet.com/mrwulf/cerebro)

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with cerebro](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with cerebro](#beginning-with-cerebro)
1. [More Advanced Usage - Configuration options and additional functionality](#more-advanced-usage)
    * [Connecting Multiple Clusters](#connecting-multiple-clusters)
    * [Limiting Access](#limiting-access)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)
1. [Release Notes](#release-notes)

## Description

This is a basic module to install and set up cerebro.

[Cerebro](https://github.com/lmenezes/cerebro) is an open source elasticsearch
web admin tool built using Scala, Play Framework, AngularJS, and Bootstrap. Cerebro
is the follow up project to Kopf- a popular elasticsearch web admin plugin.

## Setup

### Setup Requirements

Cerebro requires Java 1.8. This module does not attempt to install Java for you.

### Beginning with cerebro

A basic install will require java and the cerebro module. Cerebro will connect to the local elasticsearch instance by default.
```puppet
class { 'java': }
class { 'cerebro': }
```

## More Advanced Usage
### Connecting to multiple clusters
You can provide specific targets to connect to with an array of hashes:
```puppet
class { 'cerebro':
  targets => [ { name => 'Production Cluster',
                 host => 'http://prod:9200',
               },
               { name => 'Dev Cluster',
                 host => 'http://dev:9200',
               }, ]
}
```

Or, through Hiera and Automatic Parameter Lookup:
```yaml
cerebro::targets:
  - name: 'Production Cluster'
    host: 'http://prod:9200'

  - name: 'Dev Cluster'
    host: 'http://dev:9200'

```
### Limiting Access
You can require login with a basic challenge:
```puppet
class { 'cerebro':
  auth_type     => 'basic',
  auth_settings => {
    username => 'admin',
    password => '1234',
  }
}
```
Or through LDAP:
```puppet
class { 'cerebro':
  auth_type     => 'basic',
  auth_settings => {
    url         => 'ldap://host:port',
    base-dn     => 'ou=active,ou=Employee',
    method      => 'simple',
    user-domain => 'example.com',
  }
}
```

## Reference

* `version` Parameter: The version of Cerebro to install. Defaults to 0.7.0.
* `download_url` Parameter: The download url to use. Change this for a local repo. Defaults to "https://github.com/lmenezes/cerebro/releases/download/v${version}/cerebro-${version}.tgz".
* `install_path` Parameter: The installation path. Defaults to /opt/cerebro.
* `user` Parameter: The user to run the Cerebro service as. Defaults to cerebro.
* `group` Parameter: The group for the above user. Defaults to cerebro.
* `service` Parameter: The service name to run the Cerebro service as. Defaults to cerebro.
* `targets` Parameter: The elasticsearch endpoints to connect to. Defaults to localhost.
* `auth_type` Parameter: The authentication method to use. Options are undef, ldap, and basic. Defaults to undef which provides no authentication.
* `auth_settings` Parameter: Used with ldap and basic authentication types, allows implementation details to be provided.

## Limitations

Only tested with CentOS 7 and Elasticsearch 5 and 2. Authenticated hosts are not currently supported.

## Development

[Issues](https://github.com/mrwulf/puppet-cerebro/issues) are welcome, [pull requests](https://github.com/mrwulf/puppet-cerebro/pulls) are appreciated.

## Release Notes
### Version 0.1.1
Minor documentation updates.

### Version 0.1.0
Initial Release.
