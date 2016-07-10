# Antwort E-Mail Generator

Author: Julie Ng  
Version 0.0.12 (14 March 2016)


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
  antwort init PROJECT_NAME --key=KEY  # Initializes a new Antwort Email project
  antwort list                         # Lists all emails in the ./emails directory by id
  antwort new EMAIL_ID                 # Creates a new email template
  antwort prune                        # Removes all files in the ./build directory
  antwort send EMAIL_ID                # Sends built email via SMTP
  antwort server                       # Starts http://localhost:9292 server for coding and previewing emails
  antwort upload EMAIL_ID              # Uploads email assets to AWS S3
  antwort version                      # ouputs version number
```

__Notes__ 

- You should run the commands prefixed with `bundle exec` to make sure the correct version of gems are youed.
- `--key` refers to API key to private gem server


## License

Copyright 2014-2015 [Offsides UG](http://offsides.io). All rights reserved.