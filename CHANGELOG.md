# Change log
---

# 0.0.3

Work in progress: 3 Oct 2014

__Added__

* Added `$ antwort server` command
* Styled server pages

__Fixed__

* Fixed port number, should be 9292 instead of 9494.
* Include `lib/cli/upload` too
  

# 0.0.2

Released: 8 Sept 2014

__Added__

* Gemified antwort generator
* Added `antwort` CLI
  *   `$ antwort init MY_PROJECT` initializes the project 
  * `$ antwort new FOO_LETTER` sets up a new email 
  * `$ antwort upload FOO_LETTER` uploads the assets to Amazon S3

__Fixed__

* Create `./build` directory if it does not exist
