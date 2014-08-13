
# Setup load paths
libdir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

# Namespace
module Antwort
end

require 'antwort/builder'
require 'antwort/server'
require 'antwort/version'
require 'dotenv'
Dotenv.load
