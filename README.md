# VHOST CREATOR

## Description

This script is to ease process of creating virtual hosts on linux for apache2. Keep in mind though that it was created for my personal purposes, so if you encounter any issue, it won't be my highest priority to fix it. However, you can create issue and I will look into it.

## Usage

It is required to use root permission, `sudo` for instance. It is bash script, so set permission for executing `make_vhost.sh`. 

Enter

```
$ sudo ./make-vhost.sh example1.wip
```

Where `example1.wip` is your VHOST.

## Configuration

You can somehow configure `.conf` file that is saved to `sites-available/`. Template file is named `template.conf`.

Example of the template:

```
<VirtualHost *:80>
    ServerName ${SERVER_NAME}
    ServerAlias www.${SERVER_NAME}
    ServerAdmin webmaster@${SERVER_NAME}
    DocumentRoot ${ROOT}

    <Directory ${ROOT}>
        Options -Indexes +FollowSymLinks
        AllowOverride All
    </Directory>

    ErrorLog ${LOGS}/error.log
    CustomLog ${LOGS}/access.log combined
</VirtualHost>
```

Those variables you see there are filled in by script, so you can play a bit with it or add custom variable in script (add `export` thingy).

## Example of usage

This is an example of successfully created VHOST.

```
$ sudo ./make-vhost project.wip

============== STARTING VHOST CREATOR ==============
STATUS:		 project.wip.conf file created!
STATUS:		 /var/www/ folders created!
STATUS:		 project.wip added to /etc/hosts!
STATUS:		 Apache restarted!

VHOST successfully created! You can place your files in /var/www/project.wip/public_html!
====================================================

```

Script checks if something went wrong and in that case rollbacks any changes. So if you try to create existing VHOST or if any of files already exists, it got your back and no changes will be made to the system. Only current problem with this is if something goes wrong during writing to `/etc/hosts` or enabling and restarting apache - then it won't rollback.

Example of error:

```
$ sudo ./make_vhost.sh project.wip

============== STARTING VHOST CREATOR ==============
ERROR:		 This vhost does already exists!
====================================================
```

