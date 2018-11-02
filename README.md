# Anax CLI

[![Join the chat at https://gitter.im/canax/anax-cli](https://badges.gitter.im/canax/anax-cli.svg)](https://gitter.im/canax/anax-cli?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Latest Stable Version](https://poser.pugx.org/anax/anax-cli/v/stable)](https://packagist.org/packages/anax/anax-cli)
[![Build Status](https://travis-ci.org/canax/anax-cli.svg?branch=master)](https://travis-ci.org/canax/anax-cli)
[![CircleCI](https://circleci.com/gh/canax/anax-cli.svg?style=svg)](https://circleci.com/gh/canax/anax-cli)

A CLI client to work with Anax web sites, built in bash.



Install
------------------

This is how you download and install the skript. You can review the contents of the install script in [`src/install.bash`](src/install.bash).

```bash
bash -c "$(curl https://raw.githubusercontent.com/canax/anax-cli/master/src/install.bash)"
```

Or like this.

```bash
curl https://raw.githubusercontent.com/canax/anax-cli/master/src/install.bash | bash
```

Install using composer.

```bash
composer require anax/anax-cli
```



Usage
------------------

Check that the script works by checking its version.

```text
$ anax version
v1.1.11 (2018-10-31) 
```

Check whats can be done using the script.

```text
$ anax help                                                                
Utility to work with Anax web sites. Read more on:                         
https://dbwebb.se/anax-cli/                                                
Usage: anax [options] <command> [arguments]                                
                                                                           
Command:                                                                   
 check                    Check and display details on local environment.  
 config                   Create base for configuration in $HOME/.anax/.   
 create <dir> <template>  Create a new site in dir using a template.       
 help                     Show info on how to use it.                      
 list                     List available templates for scaffolding from.   
 list <template>          List details on specific scaffolding template.   
 selfupdate               Update to latest version.                        
 version                  Show info on how to use it.                      
                                                                           
Options:                                                                   
 --help, -h          Show info on how to use it.                           
 --version, -v       Show info on how to use it.                           
 --force, -f         Force operation even though it should not.            
```



Scaffold
------------------

List the available templates that can be scaffolded.

```text
anax list
```

List details on a template, for example  `anax-flat-site`.

```text
anax list anax-flat-site
```

Scaffold a website using the selected template and save it all to the directory `dir`.

```text
anax create dir anax-flat-site
```

The site is scaffolded and you can open your webbrowser to the site by opening `dir/htdocs`.



Processing scripts
------------------

During scaffolding a couple of scripts are executed, these are in general included with each module using to carry out the scaffolding.

The base dir for these scripts are `.anax`.



Templates for scaffolding
------------------

The templates used for scaffolding resides in [`anax/scaffold`](https://github.com/canax/scaffold).

The specific template used resides in that repo under scaffold/template-name. You can for example review the template used for [`anax-flat-site`](https://github.com/canax/scaffold/tree/master/scaffold/anax-flat-site).



License
------------------

This software carries a MIT license.



```
 .  
..:  Copyright (c) 2013 - 2018 Mikael Roos, mos@dbwebb.se
```
