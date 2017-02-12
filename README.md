# iTunes Store Transporter: GUI

[![Build Status](https://secure.travis-ci.org/sshaw/itunes_store_transporter_web.svg)](https://secure.travis-ci.org/sshaw/itunes_store_transporter_web)
[![Windows Build status](https://ci.appveyor.com/api/projects/status/cgv9vi00y0hao3tx?svg=true)](https://ci.appveyor.com/project/sshaw/itunes-store-transporter-web)
[![Code Climate](https://codeclimate.com/github/sshaw/itunes_store_transporter_web/badges/gpa.svg)](https://codeclimate.com/github/sshaw/itunes_store_transporter_web)

GUI for the iTunes Store's Transporter (iTMSTransporter)

* [Installation](#installation)
* [Configuration](#configuration)
* [API](https://github.com/sshaw/itunes_store_transporter_web/wiki/API)
* [Email Notifications](https://github.com/sshaw/itunes_store_transporter_web/wiki/Email-Notification-Templates)
* [Job Hooks](https://github.com/sshaw/itunes_store_transporter_web/wiki/Job-Hooks)
* [More Info](#more-info)

## Overview

### Job Queue

![Jobs Queue](http://sshaw.github.com/itunes_store_transporter_web/images/job-queue.png)

### Upload Packages

![Upload](http://sshaw.github.io/itunes_store_transporter_web/images/upload-form.png)

![Package Browser](http://sshaw.github.com/itunes_store_transporter_web/images/browser.png)

![Upload in Progress](http://sshaw.github.com/itunes_store_transporter_web/images/upload-running.png)

### Check Package Status

![Status Job](http://sshaw.github.com/itunes_store_transporter_web/images/status-job-results.png)

### Retrieve Metadata

![Metadata Job](http://sshaw.github.com/itunes_store_transporter_web/images/lookup-job-results.png)

### Verify Packages

![Verification Job](http://sshaw.github.com/itunes_store_transporter_web/images/verify-job-results.png)

**...and more!**

## Requirements

* Ruby >= 1.9
* [iTunes Store Transporter](http://www.apple.com/itunes/sellcontent)
* A database driver

In most cases the database driver must be compiled against an underlying database library.
**You must install the underlying library yourself**. The installer will only attempt to install the
Ruby portion which will fail if the underlying library is not found.

## Installation

    unzip itunes_store_transporter_web-VERSION.zip
    cd itunes_store_transporter_web-VERSION
    ruby ./setup.rb

Note that this *does* *not* install the iTunes Store Transporter. If you're on OS X
you can install the Transporter by [installing Xcode](https://developer.apple.com/xcode/downloads).
Otherwise, you'll have to [create an iTunes Connect account](http://www.apple.com/itunes/working-itunes/sell-content/)
and install it yourself.

Start the webserver

    ./bin/itmsweb start

Start the workers

	./bin/itmsworker jobs
    ./bin/itmsworker notifications

## Configuration

In this section `ROOT` refers to the directory containing the website. All configuration options are
set in `ROOT/config/itmsweb.yml`.

### Database

Database configuration is contained within the `database` section of the configuration file (`ROOT/config/itmsweb.yml`).
It is used by the web server *and* the worker.

By default it will contain the information provided to the setup script. Here's an example:

    # itmsweb.yml

    database:
      adapter: mysql2 # DB driver (or sqlite3, postgresql, etc...)
      database: itmsweb # DB table
      host: db.example.com
      username: sshaw
      password: ______Weee!@$%

### Webserver

#### Starting/stopping

    cd ROOT
    ./bin/itmsweb start  # start the server on 0.0.0.0 port 3000
    ./bin/itmsweb stop

#### Usage

	itmsweb <start|stop|restart> [OPTIONS]

	start options:

	-h HOST     # Bind to HOST address
	-p PORT     # Use PORT, default: 3000
	-d          # Run daemonized in the background
	-i PID      # Use PID as the PID file, default: ROOT/tmp/pids/server.pid
	-a HANDLER  # Rack Handler (default: autodetect)

	stop options:

	-i PID      # Path to PID file of running process
				# Required if you started the server with a custom PID path

#### Logging

Errors are logged to `ROOT/log/production.log`.

### Worker Processes

There are two worker process:

1. Jobs
1. Email notifications

Jobs created through the website are added to the jobs queue. In order for jobs in the queue to be processed a
worker (or many workers) must be running.

If email notifications are configured the notification worker process must be running.

#### Running a worker process

    ./bin/itmsworker TYPE

Where `TYPE` is `jobs` or `notifications`.

The jobs worker supports the `MIN_PRIORITY` and/or `MAX_PRIORITY` environment variables. These limit the worker to
jobs with certain priorities.

    MIN_PRIORITY=high ./bin/itmsworker jobs

A job's priority can be set when the job is submitted.

#### Running a remote worker process

TODO

### Website

#### File browser's root directory

The file browser's root directory defaults to the root directory of the machine running the web
server (that's `"/"`, not the web server's document root). On Windows the machine's volumes (`C:`, `D:`, etc...) will be
used instead.

This can be changed by setting `file_browser_root_directory` to the path of the desired root directory.
A list of root directories can also be used

    # itmsweb.yml

    file_browser_root_directory: /mnt/nas
    # other options...

    # Or, restrict it to a set of directories
    file_browser_root_directory:
      - /mnt/nas01
      - /mnt/nas02

Note that all directories *must* be accessable by the worker process.

There is a difference between using a single root directory and using a set of directories: if you use a single root directory
the file browser will deault to displaying *all* the files under that directory.
If multiple root directories are used the browser will default to displaying the names
of these directories, *not* their contents.

#### Preventing users from changing the Transporter path

By default the `iTMSTransporter` path can be set by visiting the config page. For client/server (i.e., non-local)
setups it might be desirable to prevent users from changing it. This can be done by setting the `allow_select_transporter_path`
option to `false`. This will prevent the config page from displaying the `iTMSTransporter` path dialog.

    # itmsweb.yml

    allow_select_transporter_path: false
    # other options...

It's best to set this option *after* setting the `iTMSTransporter` path, as there is currently
no concept of users and roles so when this is set to `false` *no* *one* will be able to change the path.

#### iTMSTransporter output logs

Everytime a worker process runs `iTMSTransporter` its output is saved and made available through the website.
By default the output logs are saved in `ROOT/var/lib/output`. This location can be changed by setting the `output_log_directory`
option to the desired directory:

    # itmsweb.yml

    output_log_directory: /mnt/log/itunes
    # other options...

This directory *must* be accessible by the worker *and* website processess.

## More Info

* [Website](http://transportergui.com)
* [Wiki](http://github.com/sshaw/itunes_store_transporter_web/wiki)
* [Source](http://github.com/sshaw/itunes_store_transporter_web)
* [Bugs](http://github.com/sshaw/itunes_store_transporter_web/issues)
* [iTunes::Store::Transporter Gem](http://github.com/sshaw/itunes_store_transporter)
* [Padrino Web Framework](http://padrinorb.com)

---

Made by [ScreenStaring](http://screenstaring.com). That's what we do.
