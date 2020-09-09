# About

This is as very simple docker configuration to run traefik locally for simple
project handling. Traefik allows you to run multiple projects simultaneously
without open port collisions.

Traefik is a HTTP proxy which automatically changes
its own configuration whenever you spin up new docker containers. It then allows access
to the web frontends by just passing all requests through itself, only needing one
public port for all projects. To differentiate the projects it uses local domain names.

So for example:
* http://web.project1.tld/ could use the web server of project1
* http://web.someotherproject.tld/ could use the web server of someotherproject

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

In order to use the integrated TSL/SSL connection you need to generate a local
self signed cert by using the provided script:

```bash
cd build/cert/
./create.sh
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

