# Antwort E-Mail Generator

Author: Julie Ng  
Date: 14 August 2014

**Documentation Todo:**

- Use `image_tag` helper
- Use 'content_for :header_css'

## Features

- local development server for live preview of markup
- builder that builds compiled html with inlined css
- test email send via SMTP

**Todo**

- [ ] sync assets to S3
- [ ] rake task to create files for new template


## Setup

### Requirements

- [Bundler](http://bundler.io/)
- Ruby 2.1
- Dotenv

## Use

### Structure

    .
    +-- .env
    +-- build
    +-- lib
    +-- source
    |   +-- assets
    |   |   +-- css
    |   |   +-- images        
    |   +-- emails
    |   +-- views
    +-- tmp


To create a new email template, for example *newsletter*, simply:

  - create a `{template}.html.erb` file in the `emails` directory
  - create a `{template}` folder in the `images` directory
  - create a `{template}` folder in the `css` directory

And your structure should look like this:
   

    source
    |
    +-- assets
    |   +-- images
    |   |   +-- newsletter
    |   |       +-- image-1.png
    |   |       +-- image-2.png
    |   +-- css
    |       +-- newsletter
    |           +-- styles.css
    |           +-- main.css
    |           +-- responsive.css
    +-- emails
        +-- newsletter.html.erb




### Test E-Mail via send

Antwort uses SMTP settings based on your `.env` file. We recommend using the [Mandrill](https://mandrillapp.com) service, which has a free tier that's perfect for testing.

If you use your own SMTP server, check if your server limits/throttles requests.

We do not support sendmail because of challenges of sending from localhost.

To send a test email, just type:

    rake send id={id} template={name} subject={optional}

### Development Server

Start the development server with the following command

    rake server

Then open `http://localhost:4567/` in your browser to view your emails. A listing of all available email templates will be automatically generated for you.


### Use as gem

- add Thor to create/copy templaate files and directories for new template
- turn antwort user on github into organization
- create user with read access
- add tokens to this user


