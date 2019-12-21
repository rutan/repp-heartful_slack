# frozen_string_literal: true

require 'repp'
require 'repp/heartful_slack/version'
require 'repp/heartful_slack/event_receive'
require 'repp/heartful_slack/message_receive'
require 'repp/heartful_slack/slack_service'
require 'repp/heartful_slack/ticker'
require 'repp/heartful_slack/ticker_event'

module Repp
  module Handler
    autoload :HeartfulSlack, 'repp/handler/heartful_slack'
    register 'heartful_slack', 'Repp::Handler::HeartfulSlack'
  end
end
