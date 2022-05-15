# BB Archive box (suitcase)
This is how we setup and deploy the services composing the archive in suitcase mode.

Checkout the [normal mode installation](https://github.com/bnei-Baruch/archive-docker) 
and the [previous (non docker) installation](https://github.com/bnei-Baruch/archive-suitcase) as well.


## Installation

Here should follow instructions on how to setup on a fresh machine.
Probably something along the lines of:

```shell script
curl -sL https://raw.githubusercontent.com/Bnei-Baruch/archive-suitcase-docker/master/host/install.sh | bash -s 

cd archive-docker
vi .env

host/post-install.sh
```


Architecture overview:
==

Archive in a box is made out of two parts (over simplified): brain and files.
Where brain stands for all apps, services, data stores, assets which are not the actual content of the archive.
These are the content files themselves (video, audio, etc...)


Disaster Recovery
==

During an unfortunate situation where network is partitioned we want a suitcase instance to serve whatever it has.
To do that a user must set his `/etc/hosts` file to the suitcase ip.

```
127.0.0.1	archive
127.0.0.1	cdn.archive
127.0.0.1	files.archive
```

Once these domains are resolved to the suitcase, the user can simply point his browser to http://archive


### Public Access
The procedure above is a manual, cumbersome and harder to do on mobile. However, there is not much we can do
upfront. Hopefully, someone with enough technical skills can setup a publicly available domain and point public 
traffic into the suitcase.
To do that you'll have to also change configuration of a few archive parts. See next part.


#### Changing Domains

Changing the domain name of the suitcase instance requires changing configuration of various components:
* nginx config files
* service config files
* CI server suitcase jobs

Once these are changed correctly, users have to setup their `/etc/hosts` file accordingly.

**nginx** Each nginx config files under `/etc/nginx/conf.d` must change its `server_name` directive to the new domain.

**TODO:** more details regarding the other two should follow
**TODO:** UI apps (react) public site + admin UI should have dynamic config. 
If not, under DR circumstances we'll need a rebuild in CI with new domains.