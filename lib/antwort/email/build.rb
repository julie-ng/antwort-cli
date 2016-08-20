require 'antwort/builders'

module Antwort
  class Build
    include Antwort::Helpers
    include Antwort::FileHelpers

    attr_reader :id

    def initialize(emails, opts = {})
      @id      = new_timestamp_id
      @emails  = emails.is_a?(Array) ? emails : [].push(emails)
      @options = opts
    end

    def create!
      @emails.each do |email_id|
        attrs = { email: email_id, id: @id }.merge(@options)
        build_email(attrs)
        build_partials(attrs) if @options[:partials]
      end
    end

    private

    def build_email(attrs)
      email = Antwort::EmailBuilder.new(attrs)
      sleep 1 until email.build!
    end

    def build_partials(attrs)
      partials = Antwort::PartialBuilder.new(attrs)
      sleep 1 until partials.build!
    end

    def new_timestamp_id
      stamp = Time.now.to_s
      stamp.split(' ')[0..1].join.gsub(/(-|:)/, '')
    end
  end
end
