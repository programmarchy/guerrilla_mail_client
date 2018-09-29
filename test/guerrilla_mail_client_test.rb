# frozen_string_literal: true

require 'test/unit'
require 'guerrilla_mail_client.rb'

class GuerrillaMailClientTest < Test::Unit::TestCase
  def setup
    @client = GuerrillaMailClient.new()
  end

  def test_email()
    result = @client.get_email_address()
    sid_token = result['sid_token']
    assert sid_token != nil

    result = @client.set_email_user('donald', sid_token: sid_token)
    assert result != nil
    
    result = @client.check_email(sid_token: sid_token)
    assert result != nil
  end
end
