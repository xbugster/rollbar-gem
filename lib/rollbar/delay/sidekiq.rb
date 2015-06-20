require 'sidekiq'

module Rollbar
  module Delay
    class Sidekiq
      OPTIONS = { 'queue' => 'rollbar', 'class' => Rollbar::Delay::Sidekiq }.freeze

      def initialize(*args)
        @options = (opts = args.shift) ? OPTIONS.merge(opts) : OPTIONS
      end

      def call(payload)
        ::Sidekiq::Client.push @options.merge('args' => [payload])
      end

      include ::Sidekiq::Worker

      def perform(*args)
        payload = Rollbar::Payload.new(args.first, Rollbar.configuration)

        Rollbar.process_payload_safely(*args)
      end
    end
  end
end
