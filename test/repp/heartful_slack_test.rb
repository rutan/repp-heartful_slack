# frozen_string_literal: true

require 'test_helper'

class HeartfulSlackTest < Test::Unit::TestCase
  test 'version' do
    assert do
      !::Repp::HeartfulSlack::VERSION.nil?
    end
  end
end
