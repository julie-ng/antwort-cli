require 'thor'
require 'dotenv'
Dotenv.load

# Namespace
module Antwort
end

require 'antwort/helpers/helper'
require 'antwort/email/collection'
require 'antwort/email/template'
require 'antwort/email/data'
require 'antwort/cli'
require 'antwort/builder'
require 'antwort/server'
require 'antwort/version'
