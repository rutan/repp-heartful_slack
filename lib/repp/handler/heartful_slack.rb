# frozen_string_literal: true

require 'slack-ruby-client'

module Repp
  module Handler
    class HeartfulSlack
      def initialize(app, options)
        @app = app
        @options = options
        setup_token
      end

      def run
        @application = @app.new
        init_ticker
        connect!
      end

      def stop
      end

      private

      def setup_token
        ::Slack.configure do |config|
          config.token = ENV['SLACK_TOKEN']
        end
      end

      def reset_client
        @web_client = nil
        @rtm_client = nil
        @slack_service = nil
      end

      def web_client
        @web_client ||= ::Slack::Web::Client.new
      end

      def rtm_client
        @rtm_client ||= ::Slack::RealTime::Client.new
      end

      def init_ticker
        @ticker = ::Repp::HeartfulSlack::Ticker.task(@application) do |res|
          post_message(res)
        end
        @ticker.slack_service = slack_service
        @ticker.run!
      end

      def connect!
        reset_client
        bind_events
        @rtm_client.start!
      rescue StandardError => e
        puts e.inspect
        sleep 1
      end

      def slack_service
        @slack_service ||= ::Repp::HeartfulSlack::SlackService.new(web_client)
      end

      def bind_events
        rtm_client.on :message, &method(:on_message)

        %i[
          bot_added
          bot_changed
          channel_archive
          channel_created
          channel_deleted
          channel_rename
          channel_unarchive
          commands_changed
          dnd_updated_user
          emoji_changed
          member_joined_channel
          member_left_channel
          pin_added
          pin_removed
          reaction_added
          reaction_removed
          subteam_created
          subteam_members_changed
          subteam_updated
          team_join
          user_change
        ].each { |type| rtm_client.on type, &method(:on_event) }
      end

      def on_message(message)
        return unless message.user

        from_user = slack_service.find_user(message.user)
        channel = slack_service.find_channel(message.channel)
        reply_to = (message.text || '').scan(/<@(\w+?)>/).map do |node|
          u = slack_service.find_user(node.first)
          u ? u.name : nil
        end

        receive = ::Repp::HeartfulSlack::MessageReceive.new(
          type: message.type,
          body: format_text(message.text),
          channel: channel,
          user: from_user,
          ts: message.ts,
          reply_to: reply_to.compact,
          raw: message,
          slack_service: slack_service
        )

        process_receive(receive)
      end

      def on_event(message)
        receive = ::Repp::HeartfulSlack::EventReceive.new(
          type: message.type,
          raw: message,
          slack_service: slack_service
        )
        process_receive(receive)

        case message.type
        when 'channel_rename'
          slack_service.refresh_channel_caches
        when 'user_change'
          slack_service.refresh_users_cache
        end
      end

      def process_receive(receive)
        res = @application.call(receive)
        post_message(res, receive)
      end

      def post_message(res, receive = nil)
        return unless res.first

        channel_to_post = detect_channel_to_post(res, receive)
        return unless channel_to_post

        attachments = res.last && res.last[:attachments]

        web_client.chat_postMessage(
          text: res.first,
          channel: channel_to_post,
          as_user: true,
          attachments: attachments
        )
      end

      def detect_channel_to_post(res, receive = nil)
        if res.last
          res.last[:channel]
        elsif receive
          receive.channel&.id
        end
      end

      def format_text(src_text)
        text = src_text.to_s.dup
        text.gsub!(/\\b/, '')
        text.gsub!(/\<\@(U[^>\|]+)\>/) do
          "@#{username_by_uid(Regexp.last_match(1))}"
        end
        text.gsub!(/\<\@(U[^\|]+)\|([^>]+)\>/) do
          "@#{username_by_uid(Regexp.last_match(1))}"
        end
        text.gsub!(/\<\#(C[^>\|]+)\>/) do
          c = slack_service.find_channel(Regexp.last_match(1))
          "##{c ? c.name : c}"
        end
        text.gsub!(/\<\#(C[^\|]+)\|([^>]+)\>/) do
          c = slack_service.find_channel(Regexp.last_match(1))
          "##{c ? c.name : c}"
        end
        text.gsub!(/<[^\|>]+\|([^>]+)>/, '\1')
        text.gsub!(/<|>/, '')
        text.gsub!(/\!(here|channel|group)/, '@\1')
        CGI.unescapeHTML(text)
      end

      def username_by_uid(uid)
        user = slack_service.find_user(uid)
        return uid unless user

        if user.profile && !user.profile.display_name.to_s.empty?
          user.profile.display_name
        else
          user.name
        end
      end

      class << self
        def run(app, options = {})
          handler = HeartfulSlack.new(app, options)
          yield handler if block_given?
          handler.run
        end
      end
    end
  end
end
