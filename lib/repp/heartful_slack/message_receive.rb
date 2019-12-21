# frozen_string_literal: true

module Repp
  module HeartfulSlack
    class MessageReceive < ::Repp::Event::Receive
      interface :channel, :user, :type, :ts, :reply_to, :raw, :slack_service

      def bot?
        !!@is_bot
      end

      def bot=(switch)
        @is_bot = switch
      end
    end
  end
end
