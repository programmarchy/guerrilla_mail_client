# frozen_string_literal: true

require 'cgi'
require 'json'
require 'openssl'
require 'net/https'

class GuerrillaMailClient
  def initialize(site: ENV['GUERRILLA_MAIL_SITE'], api_key: ENV['GUERRILLA_MAIL_API_KEY'])
    @site = site
    @api_key = api_key
    @http = Net::HTTP.new('api.guerrillamail.com', 443)
    @http.use_ssl = true
    @http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  end

  def build_url(f, sid_token: nil)
    url = String.new "/ajax.php?f=#{CGI::escape(f)}"

    unless sid_token.to_s.empty?
      url << build_url_param('sid_token', sid_token)
    end

    unless @site.to_s.empty?
      url << build_url_param('site', @site)
    end

    url
  end

  def build_url_param(key, value)
    "&#{CGI::escape(key)}=#{CGI::escape(value.to_s)}"
  end

  def get_email_address(lang: 'en', sid_token: nil)
    url = build_url('get_email_address', sid_token: sid_token)

    unless lang.to_s.empty?
      url << build_url_param('lang', lang)
    end

    req = Net::HTTP::Get.new(url)
    res = @http.request(req)
    JSON.parse(res.body)
  end

  def api_token(sid_token:)
    if @api_key.to_s.empty?
      return nil
    end

    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), @api_key, sid_token)
  end

  def authorize(req, sid_token:)
    api_token = self.api_token(sid_token: sid_token)
    unless api_token.to_s.empty?
      req['Authorization'] = "ApiToken: #{api_token}"
    end
  end

  def set_email_user(email_user, lang: 'en', sid_token:)
    url = build_url('set_email_user', sid_token: sid_token)

    url << build_url_param('email_user', email_user)

    unless lang.to_s.empty?
      url << build_url_param('lang', lang)
    end

    req = Net::HTTP::Get.new(url)
    res = @http.request(req)
    authorize(req, sid_token: sid_token)
    JSON.parse(res.body)
  end

  def check_email(seq: 0, sid_token:)
    url = build_url('check_email', sid_token: sid_token)

    url << build_url_param('seq', seq)

    req = Net::HTTP::Get.new(url)
    res = @http.request(req)
    authorize(req, sid_token: sid_token)
    JSON.parse(res.body)
  end

  def fetch_email(email_id, sid_token:)
    url = build_url('fetch_email', sid_token: sid_token)

    url << build_url_param('email_id', email_id)

    req = Net::HTTP::Get.new(url)
    res = @http.request(req)
    authorize(req, sid_token: sid_token)
    JSON.parse(res.body)
  end
end
