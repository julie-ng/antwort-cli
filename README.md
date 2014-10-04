# Antwort E-Mail Generator

Author: Julie Ng  
Version 0.0.3 (October 2014)

### Speed up your email design and development workflow by automating repetitive tasks:

- design in code with live preview of markup using Antwort's local development server
- build html and inline css from multiple templates
- upload images to content server (S3 only)
- send email test via SMTP

__Other features__


- useful helpers, e.g. `image_tag` that automatically includes email specific markup.

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
    SMTP_EMAIL:             {{default_recipient}}

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


To create a new email template, for example `newsletter`, simply run:

```
bundle exec antwort new newsletter
```


## Commands


### Antwort commands


```
Commands:
  antwort help [COMMAND]               # Describe available commands or one specific command
  antwort init PROJECT_NAME --key=KEY  # Initializes a new Antwort project
  antwort new EMAIL_ID                 # Creates a new Antwort email
  antwort upload EMAIL_ID              # Uploads an Antwort email to Amazon S3
```

__Notes__ 

- You should run the commands prefixed with `bundle exec` to make sure the correct version of gems are youed.
- `--key` refers to API key to private gem server


### Rake tasks

```
bundle exec rake -T
```

```
rake build:clean     # Empties the build directory
rake build:template  # Builds Markup from template (required: id=template_name})
rake send            # Sends email via SMTP by id={template_name} email={recipient} (optional: subject={subject_line})
rake server          # Starts http://localhost:9292 server for developing emails
```


## License

Copyright 2014 [Offsides UG](http://offsides.io). All rights reserved.