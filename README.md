# About

This is as very simple docker configuration to run traefik locally for simple
project handling. Traefik allows you to run multiple projects simultaneously
without open port collisions.



## More background

Traefik is a HTTP proxy which automatically changes
its own configuration whenever you spin up new docker containers. It then allows access
to the web frontends by just passing all requests through itself, only needing one
public port for all projects. To differentiate the projects it uses local domain names.

So for example:
* http://web.project1.t23dev/ could use the web server of project1
* http://web.someotherproject.t23dev/ could use the web server of someotherproject

# Install

To get things up and running you just **need to have docker installed**:

## Initial setup

```bash
b5 install
b5 update
```

## Running the project

```bash
b5 run
```

## Housekeeping

```bash
b5 update
```

# Your projects with traefik

To use traefik you will need to setup a local domain and adjust the project
configuration accordingly.

## Providing a local domain

Traefik needs a local domain to differentiate the projects you use. The domain name
will make traefik choose the right backend container.

We use dnsmasq as a local nameservier for accomplishing that. Setup is as follows:
```shell
$ brew update  # make sure we are up to date
$ brew install dnsmasq  # install dnsmasq
$ cd $(brew --prefix)  # cd into /usr/local
$ mkdir -p etc  # make sure /usr/local/etc exists
$ echo 'address=/.a25dev/127.0.0.1' > etc/dnsmasq.conf  # setup local dns resolving
$ sudo cp -v $(brew --prefix dnsmasq)/homebrew.mxcl.dnsmasq.plist /Library/LaunchDaemons  # Enable dnsmasq daemon
$ sudo launchctl load -w /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist  # And start the daemon ;-)
$ sudo mkdir -p /etc/resolver  # make sure /etc/resolver exists
$ sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/a25dev'  # tell macOS to use the local dnsmasq nameserver for .a25dev
```
A reboot might be needed for changes to take effect.


## Example project configuration

To get your projects running with traefik I suggest the following schema:
* docker-compose.yml: Use this file to define all the services you need. DO NOT
  open any ports here.
* docker-compose.localhost.yml: This file for opening the local ports, like
  localhost:8000. This file can be used by anyone not caring about traefik and
  should be the default configuration.
* docker-compose.traefik.yml: Neccessary changes to the configuration to get traefik
  up and running. Basically adding the neccessary network and label options.

With b5 you should use `docker_compose_config_overrides` to choose the used additional
configuration file. This should default to 'localhost', developers might use local.yml
to change it to 'traefik'.

### config.yml

```yaml
# This is the central configuration for all tools we use/execute. It is parsed inside
# the Taskfile, too. See $CONFIG_project_name for example.
project:
  name: Example traefik project
  key: traefik_example
  url: http://www.doesnotexistyet.com/
paths:
  web: ../web
modules:
  # THIS is the important bit. Loading docker-compose.localhost.yml
  docker:
    docker_compose_config_overrides: localhost
```

### docker-compose.yml

**Note:** I use the official phpmyadmin container for this example, as it is ready to
use without any complex configuration (only one service, no volumes, …). For example
purposes I skipped the neccessary MySQL server.

```yaml
version: '3'

services:
  phpmyadmin:
    image: phpmyadmin/phpmyadmin
```

### docker-compose.localhost.yml

In this file we open the normal ports for localhost:PORT usage. As a convention
we use port 8001 for phpmyadmin.

```yaml
version: '3'

services:
  phpmyadmin:
    ports:
      - "8001:80"
```

### docker-compose.traefik.yml

Now we add the configuration necessary for traefik to pick up the service and
provide the proxy services we want.


**Note:** when typing in the domain name yourself Google Chrome might open up
the normal google search as .t23dev is no common domain name. Type a trailing slash
to force the browser to use HTTP directly. So open up 'phpmyadmin.traefikexample.t23dev/'
in your addess bar will work.
