# Change log

## 0.0.8

__Added__

* Refactored Builder to generate both templates and partials
* Added `SEND_FROM` environment variable to use as sender address, in case it differs from SMTP username.

__Fixed__

* Make sure partials always have `.html` file extension, in case file is named `_partial.erb`

__Updated__

* Various code cleanup

## 0.0.7

13 Nov 2014

__Added__

* Added `data/config.yml` to store global defaults, e.g. button colors. Updated new project templates to reflect this.

__Updated__

* Changed button markup to use Litmus Bulletproof strategy
* Updated CSS organization; use underscore prefixes for included styles
* Only parses data YAML if we have it; fixes errors from `symbolize_keys!` on `false`

__Removed__

* Removed Rake tasks remnants, including `Rakefile`
* Removed `Sinatra::ConfigFile`


## 0.0.6

6 Nov 2014

__Added__

* Added `$antwort remove [EMAIL_ID]` command to remove emails, incl. css and image assets
* Allows upload of shared images directory via `$antwort upload shared`
* New emails get a blank title
* Add username password to new project `init`

__Fixed__

* Defaults border color to background color if no border color is defined
* Always render 404 with content_type `text/html`


## 0.0.5

15 Oct 2014

__Added__

* Added `$ antwort send [EMAIL_ID]` command to send emails
* Added `$ antwort list` command to list all emails

__Fixed__

* Respect port number option when running server

__Removed__

* Removed `send.rake`
* Removed duplicate dotenv load in `upload.rb`


## 0.0.4

13 Oct 2014

__Added__

* Added `$ antwort build` command to build emails
* Added `$ antwort prune` command to empty `./build` directory
* Added `$ antwort version` to output version, with `--version` option on executable
* Made `bundle` and `git init` optional when initializing new antwort project
* Various CLI output improvements
* Various new project template improvements

__Removed__

* Removed `build.rake` tasks after integrating them into antwort executable


## 0.0.3

7 Oct 2014

__Added__

* Added `$ antwort server` command
* Styled server pages

    - Lists all templates by title
    - If no templates, shows message to add one
    - Styled 404 template not found page
* Refactored Builder

    - Builder now uses regex to remove rack live reload code
    - Cleaned up CSS markup required for inlining css. Removed `roadie` references from project templates.
    - Templates now use just `styles.scss` (inlined) and `responsive.scss` (outputed to `<head>`)
* Individual email metadata via YAML frontmatter
* Custom layouts per email via metadata
* Adjusted templates included in project initializer based on code changes
* Added some specs for Antwort::Server


__Fixed__

* Fixed port number, should be 9292 instead of 9494.
* Include `lib/cli/upload` too
* `image_tag` now respects absolute URLs starting with `http:` or `https:`
* `image_tag` only prefxes template directory to path if image src does *not* start with `/`
  

## 0.0.2

Released: 8 Sept 2014

__Added__

* Gemified antwort generator
* Added `antwort` CLI
  *   `$ antwort init MY_PROJECT` initializes the project 
  * `$ antwort new FOO_LETTER` sets up a new email 
  * `$ antwort upload FOO_LETTER` uploads the assets to Amazon S3

__Fixed__

* Create `./build` directory if it does not exist
