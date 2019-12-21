# repp-heartful_slack

> repp-heartful_slack is a powerful handler of [Repp](https://github.com/kinoppyd/repp) for [Slack](https://slack.com).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'repp-heartful_slack'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install repp-heartful_slack

## Usage

in [Mobb](https://github.com/kinoppyd/mobb)

```ruby
require 'mobb'
require 'repp/heartful_slack'

set :service, 'heartful_slack'

set :on_message do |_|
  condition {@env.kind_of?(::Repp::HeartfulSlack::MessageReceive)}
end

set :on_event do |_|
  condition {@env.kind_of?(::Repp::HeartfulSlack::EventReceive)}
end

set :to_notify do |_|
  dest_condition do |res|
    res.last[:channel] = ENV['NOTIFY_CHANNEL'] # ex. Cxxxxxxx
  end
end

on 'emoji_changed', on_event: true, to_notify: true do
  case @env.raw.subtype
  when 'add'
    "new emoji -> :#{@env.raw.name}:"
  when 'remove'
    "removed emoji -> #{@env.raw.names.map { |name| ":#{name}:" }.join(' ')}"
  end
end
```

see `sample/app.rb`

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
