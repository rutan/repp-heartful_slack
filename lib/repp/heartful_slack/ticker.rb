# frozen_string_literal: true

module Repp
  module HeartfulSlack
    class Ticker < ::Repp::Ticker
      attr_accessor :slack_service

      def run!
        @task = Concurrent::TimerTask.new(execution_interval: 1) do
          next unless slack_service

          @block.call(Task.new.tick(TickerEvent.new(
                                      body: Time.now,
                                      slack_service: slack_service
                                    )))
        end
        @task.execute
      end
    end
  end
end
