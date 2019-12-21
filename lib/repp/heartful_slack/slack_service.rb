# frozen_string_literal: true

module Repp
  module HeartfulSlack
    class SlackService
      attr_reader :web_client

      def initialize(web_client)
        @web_client = web_client
        refresh
      end

      def refresh
        refresh_users_cache
        refresh_channel_caches
      end

      def refresh_users_cache
        @user_caches = {}

        resp = web_client.users_list
        return unless resp.ok

        resp.members.each do |member|
          @user_caches[member.id] = member
        end
      end

      def find_user(uid)
        return @user_caches[uid] if @user_caches.key?(uid)

        resp = web_client.users_info(user: uid)
        @user_caches[uid] = resp.ok ? resp.user : nil
      end

      def refresh_channel_caches
        @channel_caches = {}

        resp = web_client.channels_list
        return unless resp.ok

        resp.channels.each do |channel|
          @channel_caches[channel.id] = channel
        end
      end

      def find_channel(uid)
        return @channel_caches[uid] if @channel_caches.key?(uid)

        resp = web_client.conversations_info(channel: uid)
        return @channel_caches[uid] = resp.channel if resp.ok

        resp = web_client.groups_info(channel: uid)
        return @channel_caches[uid] = resp.group if resp.ok

        @channel_caches[uid] = nil
      end

      def post(text:, channel:, attachments: [], as_user: true, name: nil, emoji: nil)
        web_client.chat_postMessage({
          text: text,
          channel: channel,
          as_user: as_user,
          username: name,
          icon_emoji: ":#{emoji}:",
          attachments: attachments
        }.delete_if { |_, v| v.nil? })
      end
    end
  end
end
