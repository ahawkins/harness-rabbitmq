require "harness/rabbitmq/version"

require 'harness'

require 'uri'
require 'net/http'
require 'multi_json'

module Harness
  class RabbitmqGauge
    include Instrumentation

    BadResponseError = Class.new StandardError

    def initialize(url)
      @url = url
    end

    def log
      response = Net::HTTP.get_response URI(@url)

      if response.code.to_i != 200
        raise BadResponseError, "Server did not respond correctly! #{response.inspect}"
      end

      body = MultiJson.load response.body

      body.each do |exchange|
        next unless exchange.key? 'message_stats'
        name, stats = exchange.fetch('name'), exchange.fetch('message_stats')

        if stats.key?('confirm')
          gauge "rabbitmq.#{name}.confirmed.count", stats.fetch('confirm')
          gauge "rabbitmq.#{name}.confirmed.rate", stats.fetch('confirm_details').fetch('rate')
        end

        if stats.key?('publish_in')
          gauge "rabbitmq.#{name}.published.count", stats.fetch('publish_in')
          gauge "rabbitmq.#{name}.published.rate", stats.fetch('publish_in_details').fetch('rate')
        end

        if stats.key?('publish_out')
          gauge "rabbitmq.#{name}.consumed.count", stats.fetch('publish_out')
          gauge "rabbitmq.#{name}.consumed.rate", stats.fetch('publish_out_details').fetch('rate')
        end
      end
    end
  end
end
