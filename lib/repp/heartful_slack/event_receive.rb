# frozen_string_literal: true

module Repp
  module HeartfulSlack
    class EventReceive < ::Repp::Event::Receive
      interface :type, :raw, :slack_service

      def body
        type.to_s
      end

      def reply_to
        []
      end
    end
  end
end
