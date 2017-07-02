# Antwort E-Mail Generator

[![Build Status](https://travis-ci.org/jng5/antwort-cli.svg?branch=master)](https://travis-ci.org/jng5/antwort-cli)

Author: Julie Ng  
Version 1.0.1 (2 July 2017)

### Speed up your email design and development workflow:

- design in code with **live preview** of markup using Antwort's local development server
- **build html** and **inline css** from multiple templates
- **upload images** to content server (S3 only)
- **send email** test via SMTP
- includes **useful helpers**, e.g. `image_tag` that automatically includes email specific markup.

See [CHANGELOG.md](https://github.com/jng5/antwort-generator/blob/master/CHANGELOG.md) for full functionality list.

## Setup

### Requirements

- [Bundler](http://bundler.io/)
- Ruby 2.0+
- AWS S3 Account, for email upload (optional)
- SMTP credentials, for sending test emails (optional)

### Environment 

In the project root, create a `.env` file with the following attributes


    ASSET_SERVER:           https://example.s3.amazonaws.com
    AWS_ACCESS_KEY_ID:      {{aws_access_key_id}}
    AWS_SECRET_ACCESS_KEY:  {{aws_secret_access_key}}  
    AWS_BUCKET:             example
    FOG_REGION:             eu-west-1
                            
    SMTP_SERVER:            smtp.mandrillapp.com
    SMTP_PORT:              587
    SMTP_USERNAME:          {{username}}
    SMTP_PASSWORD:          {{password}}
    SMTP_DOMAIN:            {{domain}}
    SEND_TO:                {{default_recipient}}
    SEND_FROM:              {{default_sender}}

See `.env.sample` for an example.

## Use

### Structure

    .
    +-- .env
    +-- build
    +-- assets
    |   +-- css
    |   +-- images
    +-- emails
    +-- views
    +-- tmp


To create a new email template, for example `newsletter`, simply run: `bundle exec antwort new newsletter` and all the proper files will be created for you.



## Commands


```
Commands:
  antwort build EMAIL_ID               # Builds email markup and inlines CSS from source
  antwort help [COMMAND]               # Describe available commands or one specific command
  antwort init PROJECT_NAME            # Initializes a new Antwort Email project
  antwort list                         # Lists all emails in the ./emails directory by id
  antwort new EMAIL_ID                 # Creates a new email template
  antwort prune                        # Removes all files in the ./build directory
  antwort send EMAIL_ID                # Sends built email via SMTP
  antwort server                       # Starts http://localhost:9292 server for coding and previewing emails
  antwort upload EMAIL_ID              # Uploads email assets to AWS S3
  antwort version                      # ouputs version number
```

__Notes__ 

- You should run the commands prefixed with `bundle exec` to make sure the correct version of gems are used.


## License (MIT)

Copyright (c) 2014-2016 Julie Ng.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.