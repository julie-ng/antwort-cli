# Change Log

## 1.0.0

Released: 31 October 2016

This release jumped to version 1.0 because it is not compatible with previously generated projects. This update features a great deal of refactoring under the hood:

__Added__

* Send test emails to multiple recipients.

__Refactored__

* Extracted code into models: `EmailCollection`, `EmailData`, `EmailTemplate`.
* Re-organized CLI code to leverage new classes.
* Re-organized helpers.
* Cleaned up and removed unused files.
* Internalized server code, removing it from project code.
* Added more spces.
* Added more ruby conventions to method names, esp. `?` and `!` in method names.
* Ran code through rubocop.

__Fixed__

* various template bugs, e.g. missing/unused variables.


## 0.0.12

Released: 14 March 2016

__Fixed__

* Preserve multiline partials
* Fixed typo in image tag markup. It should be `style=""`.

__Updated__

* Sending a test email now uses the email's `<title>` as the subject line, prefixed by "[test] "
* Change CSS output style short flag to -c, more logical than -o
* Our `include.scss` is now added after `<title>` instead of just before `</head>`, so we do not accidentlly override email specific included CSS.
* `data-roadie-` attributes are removed after inlining.
* Updated some templates used when initializing a new project


## 0.0.11

Released: 2 December 2015

In this release, Partial Inlining was updated, not just to add and fix missing logic, but more importantly to establish syntax patterns.

__Added__

* New `--all` flag to `build` command, which will build all emails.
* `each_with_index` loops are also now preserved. Example conversion: `cats.each_with_index do |cat, i|` becomes `{% for cat in cats with: {@index: i} %}`
* Locals passed to partials are now referenced using a more generic `with` instead of ruby-esqe `locals` like so: `{% partial 'foo' with: {size: 1} %}`
* ERB's `unless` is  now converted to `if !(condition)` 
* ERB Statements without output or conditionals are also now preserved. Example: `<% product.merge({featured: false}) %>`
* `button` and `image_tag` helpers are converted to use statement `{% … %}` syntax, not `{{ … }}` output syntax

__Fixed__

* Inlining partials no longer results in extra `<p>` tags. They were added by Nokogiri to create complete DOM trees should be addressed.
* Fixed edge cases where conditionals using a less than `<` operator resulted in large chunks of missing code. Nokogiri, interpreted it as the start of an HTML tag, often chopping off parts until it found the next orphaned `>`, often in another conditional.
* Antwort now always sends the correct email by matching `email_id`s exactly (#45).

__Updated__

* Closing logic tags are now simply `{% end %}`, deviating from Twig's `{% endif %}` and `{% endfor %}`, which cannot reliably be captured using regular expressions. We're choosing consistency and reliability over strict adherence to Twig syntax.
* Updated some specs to test conversion of ERB logic to Twig-style logic.

## 0.0.10

Released: 15 November 2015

__Added__

* New Feature: `--css-style` or `-o` flag for [Sass output style](http://sass-lang.com/documentation/file.SASS_REFERENCE.html#output_style). Possible values: `expanded, `nested`, `compact`, or `compressed`.
* Building partials now also builds the emails

__Fixed__

* Adding and removing emails now also adds and removes respective `data/[email_id].yml` data file.

__Updated__

* `symbolize_keys` helper is now a generic antwort helper.

## 0.0.9

Released: 20 Oct 2015

__Added__
* Preserve more logic for partials, including:
  - conditionals
  - variables
  - varibles in lines
  - non brekaing spaces
  - code comments
  - assignments including `||=` asssignments
* add Yahoo table `align="center"` workaround to inline css.

__Breaking Changes__

* Stylesheets have been renamed to more accurately reflect how they are integrated into the email.
  - `styles.scss` is now `inline.scss`, because it will be inlined.
  - `responsive.scss` is now `include.scss`, because it will be included in the `<head>`, not all of which are responsive styles. Some are just CSS resets.
* Meta data variables are now set directly as instance variables and can be accessed directly. For example, use `@title` instead of `@metadata[:title]`

__Fixed__
* Create `./build` directory if it doesn't exist (#30)
* Build email before send if not already built and inlined (#31)
* Restore variables inside links (#32)
* Make default server layout responsive (#29)
* [`Sinatra::ContentFor`](http://www.sinatrarb.com/contrib/content_for.html) helper now works

__Updated__
* Cleaned up existing and added more specs
* Update `.env.sample` defaults and add missing `SEND_FROM`


## 0.0.8

Released: 12 Jan 2015

__Added__

* Added `SEND_FROM` environment variable to use as sender address, in case it differs from SMTP username
* Refactored Builder to generate both templates and partials
* Preserve ERB code in partials by changing to [Twig](http://twig.sensiolabs.org/) syntax, which is ignored by our inliner.

__Fixed__

* Make sure partials always have `.html` file extension, in case file is named `_partial.erb`
* Default buttons now work in Outlook (missing border property)
* Default email now also responsive (missing media query)
* Prevent double slashes in image asset URLs when building templates without an `ASSET_SERVER` environment variable
* Only creates a build subfolder if it exists
* Preserves `&nbsp;` in code

__Updated__

* Various code cleanup
* Updated project templates
  * Added default font styles
  * Updated meta tags in layout to support media queries on Windows Phone  
  * Added more getting started text in demo email
  * Added sample placeholder image for `image_tag` example
  * Added `button` helper examples
  * Added examples using partials
  * Updated sample .ruby-version to use latest version of ruby
  * Removed deprecated button defualts via `config.yml`. Use CSS instead


## 0.0.7

Released: 13 Nov 2014

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

Released: 6 Nov 2014

__Added__

* Added `$antwort remove [EMAIL_ID]` command to remove emails, incl. css and image assets
* Allows upload of shared images directory via `$antwort upload shared`
* New emails get a blank title
* Add username password to new project `init`

__Fixed__

* Defaults border color to background color if no border color is defined
* Always render 404 with content_type `text/html`


## 0.0.5

Released: 15 Oct 2014

__Added__

* Added `$ antwort send [EMAIL_ID]` command to send emails
* Added `$ antwort list` command to list all emails

__Fixed__

* Respect port number option when running server

__Removed__

* Removed `send.rake`
* Removed duplicate dotenv load in `upload.rb`


## 0.0.4

Released: 13 Oct 2014

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

Released: 7 Oct 2014

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
