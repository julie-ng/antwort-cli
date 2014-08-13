require 'sinatra/base'
require 'sinatra/extension'
require 'sprockets'
require 'sprockets-sass'

module Sinatra
  module Assets
    extend Sinatra::Extension

    configure do
      set :assets, assets = Sprockets::Environment.new(root)
      assets.append_path 'assets/css'
      assets.append_path 'assets/images'

      assets.cache = Sprockets::Cache::FileStore.new('./tmp')
    end

    get '/assets/*' do
      env['PATH_INFO'].sub!(%r{^/assets}, '')
      settings.assets.call(env)
    end

  end
end
