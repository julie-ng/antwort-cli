# Antwort E-Mail Generator

Author: Julie Ng  
Date: 14 August 2014

**Documentation Todo:**

- Use `image_tag` helper
- Use `content_for :header_css`

## Features

- local development server for live preview of markup
- builder that builds compiled html with inlined css
- test email send via SMTP

**Todo**

See [Issues](https://github.com/jng5/antwort-generator/issues)

## Setup

### Requirements

- [Bundler](http://bundler.io/)
- Ruby 2.1
- Dotenv

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


To create a new email template, for example *newsletter*, simply run:

```bash
$ bundle exec antwort new newsletter
```

### Test E-Mail via send

Antwort uses SMTP settings based on your `.env` file.
We recommend using the [Mandrill](https://mandrillapp.com) service, which has a free tier that's perfect for testing.

If you use your own SMTP server, check if your server limits/throttles requests.

We do not support sendmail because of challenges of sending from localhost.

To send a test email, just type:

```bash
$ rake send id={optional} template={name} subject={optional}
```

### Development Server

Start the development server with the following command

```bash
$ rake server
```

Then open `http://localhost:9494/` in your browser to view your emails.
A listing of all available email templates will be automatically generated for you.

### Available commands

## `antwort` executable

```bash
bundle exec antwort
```

```
Commands:
  antwort help [COMMAND]               # Describe available commands or one specific command
  antwort init PROJECT_NAME --key=KEY  # Initializes a new Antwort project
  antwort new EMAIL_ID                 # Creates a new Antwort email
  antwort upload EMAIL_ID              # Uploads an Antwort email to Amazon S3
```

## Rake tasks

```bash
$ bundle exec rake -T
```

```
rake build:clean     # Empties the build directory
rake build:template  # Builds Markup from template (required: id=template_name})
rake send            # Sends email via SMTP by id={template_name} email={recipient} (optional: subject={subject_line})
rake server          # Starts http://localhost:9292 server for developing emails
```
