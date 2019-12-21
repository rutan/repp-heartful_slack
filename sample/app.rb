# frozen_string_literal: true

require 'mobb'
require 'repp/heartful_slack'

set :service, 'heartful_slack'

set :on_message do |_|
  condition { @env.is_a?(::Repp::HeartfulSlack::MessageReceive) }
end

set :on_event do |_|
  condition { @env.is_a?(::Repp::HeartfulSlack::EventReceive) }
end

set :to_notify do |_|
  dest_condition do |res|
    res.last[:channel] = ENV['NOTIFY_CHANNEL'] # ex. Cxxxxxxx
  end
end

on 'ping', on_message: true do
  'pong'
end

on 'channel_archive', on_event: true, to_notify: true do
  channel = @env.slack_service.find_channel(@env.raw.channel)
  "archive -> <##{channel.id}>"
end

on 'channel_created', on_event: true, to_notify: true do
  "created -> <##{@env.raw.channel.id}>"
end

on 'channel_deleted', on_event: true, to_notify: true do
  channel = @env.slack_service.find_channel(@env.raw.channel)
  next unless channel

  "deleted -> `##{channel.name}`"
end

on 'channel_rename', on_event: true, to_notify: true do
  old_name = @env.slack_service.find_channel(@env.raw.channel.id)&.name
  "rename `#{old_name}` -> <##{@env.raw.channel.id}>"
end

on 'channel_unarchive', on_event: true, to_notify: true do
  channel = @env.slack_service.find_channel(@env.raw.channel)
  "unarchive -> <##{channel.id}>"
end

on 'emoji_changed', on_event: true, to_notify: true do
  case @env.raw.subtype
  when 'add'
    "new emoji -> :#{@env.raw.name}:"
  when 'remove'
    "removed emoji -> #{@env.raw.names.map { |name| ":#{name}:" }.join(' ')}"
  end
end

on 'subteam_created', on_event: true, to_notify: true do
  "new subteam: #{@env.raw.subteam.handle}"
end

on 'team_join', on_event: true, to_notify: true do
  "new member -> <#{@env.raw.user.id}>"
end

on 'user_change', on_event: true, to_notify: true do
  old_user = @env.slack_service.find_user(@env.raw.user.id)
  if @env.raw.user.deleted != old_user.deleted
    if @env.raw.user.deleted
      "zuttomo member -> <#{@env.raw.user.id}>"
    else
      "reactivate member -> <#{@env.raw.user.id}>"
    end
  end
end
