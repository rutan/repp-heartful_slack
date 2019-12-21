# frozen_string_literal: true

module Repp
  module HeartfulSlack
    class TickerEvent < ::Repp::Event::Ticker
      interface :slack_service
    end
  end
end
