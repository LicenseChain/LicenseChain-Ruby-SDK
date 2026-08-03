# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'
require 'openssl'
require 'base64'
require 'time'
require 'securerandom'

module LicenseChain
  # Enhanced client with reverse-engineered advanced patterns
  class EnhancedClient < Client
    attr_reader :session_id, :user_data, :initialized

    def initialize(app_name:, owner_id:, app_secret:, base_url: 'https://api.licensechain.app/v1', timeout: 30, retries: 3)
      super
      @session_id = nil
      @user_data = nil
      @initialized = false
    end

    # Initialize the client and establish connection
    def init
      return true if @initialized

      response = make_request('init', {
        type: 'init',
        ver: '1.0',
        hash: generate_hash,
        enckey: generate_encryption_key,
        name: @app_name,
        ownerid: @owner_id
      })

      if response['success']
        @session_id = response['sessionid']
        @initialized = true
        true
      else
        false
      end
    end

    # License-only login (advanced pattern)
    def license_login(license:)
      ensure_initialized
      
      response = make_request('license', {
        type: 'license',
        key: license,
        hwid: get_hwid
      })

      if response['success']
        @user_data = response['info']
        response
      else
        raise LicenseChainError, response['message'] || 'License login failed'
      end
    end

    # Check if user is logged in
    def logged_in?
      !@user_data.nil?
    end

    # Get current user data
    def user_data
      @user_data
    end

    # Get user's subscription information
    def subscription
      return nil unless logged_in?
      @user_data['subscriptions']
    end

    # Set user variable
    def setvar(var:, data:)
      ensure_logged_in
      
      response = make_request('setvar', {
        type: 'setvar',
        var: var,
        data: data,
        sessionid: @session_id
      })

      response['success']
    end

    # Get user variable
    def getvar(var:)
      ensure_logged_in
      
      response = make_request('getvar', {
        type: 'getvar',
        var: var,
        sessionid: @session_id
      })

      response['success'] ? response['data'] : nil
    end

    # Log message to LicenseChain
    def log(message:)
      ensure_logged_in
      
      response = make_request('log', {
        type: 'log',
        pcuser: get_pc_user,
        message: message,
        sessionid: @session_id
      })

      response['success']
    end

    # Download file from LicenseChain
    def download(fileid:)
      ensure_logged_in
      
      response = make_request('file', {
        type: 'file',
        fileid: fileid,
        sessionid: @session_id
      })

      response['success'] ? response['contents'] : nil
    end

    # Get application statistics
    def app_stats
      ensure_initialized
      
      response = make_request('app', {
        type: 'app',
        sessionid: @session_id
      })

      response['success'] ? response : nil
    end

    # Get online users
    def online_users
      ensure_logged_in
      
      response = make_request('online', {
        type: 'online',
        sessionid: @session_id
      })

      response['success'] ? response['users'] : nil
    end

    # Chat functionality
    def chat_get(channel:)
      ensure_logged_in
      
      response = make_request('chatget', {
        type: 'chatget',
        channel: channel,
        sessionid: @session_id
      })

      response['success'] ? response['messages'] : nil
    end

    def chat_send(message:, channel:)
      ensure_logged_in
      
      response = make_request('chatsend', {
        type: 'chatsend',
        message: message,
        channel: channel,
        sessionid: @session_id
      })

      response['success']
    end

    # Admin functions
    def ban_user(user:)
      ensure_logged_in
      
      response = make_request('ban', {
        type: 'ban',
        user: user,
        sessionid: @session_id
      })

      response['success']
    end

    def unban_user(user:)
      ensure_logged_in
      
      response = make_request('unban', {
        type: 'unban',
        user: user,
        sessionid: @session_id
      })

      response['success']
    end

    def all_users
      ensure_logged_in
      
      response = make_request('allusers', {
        type: 'allusers',
        sessionid: @session_id
      })

      response['success'] ? response['users'] : nil
    end

    def get_user(username:)
      ensure_logged_in
      
      response = make_request('getuser', {
        type: 'getuser',
        user: username,
        sessionid: @session_id
      })

      response['success'] ? response['info'] : nil
    end

    def update_user(user:, data:)
      ensure_logged_in
      
      response = make_request('edituser', {
        type: 'edituser',
        user: user,
        data: data,
        sessionid: @session_id
      })

      response['success']
    end

    def delete_user(user:)
      ensure_logged_in
      
      response = make_request('deleteuser', {
        type: 'deleteuser',
        user: user,
        sessionid: @session_id
      })

      response['success']
    end

    # Webhook functionality
    def webhook
      ensure_logged_in
      
      response = make_request('webhook', {
        type: 'webhook',
        sessionid: @session_id
      })

      response['success'] ? response : nil
    end

    def verify_webhook(payload:, signature:)
      expected_signature = generate_webhook_signature(payload)
      expected_signature == signature
    end

    def parse_webhook(payload:, signature:)
      return nil unless verify_webhook(payload: payload, signature: signature)
      
      JSON.parse(payload)
    rescue JSON::ParserError
      nil
    end

    private

    def ensure_initialized
      raise LicenseChainError, 'Client not initialized. Call init() first.' unless @initialized
    end

    def ensure_logged_in
      ensure_initialized
      raise LicenseChainError, 'User not logged in' unless logged_in?
    end

    def generate_hash
      data = "#{@app_name}#{@owner_id}#{@app_secret}"
      Digest::SHA256.hexdigest(data)
    end

    def generate_encryption_key
      SecureRandom.hex(16)
    end

    def get_hwid
      require 'socket'
      require 'sys/uname'
      
      hostname = Socket.gethostname
      uname = Sys::Uname.uname
      "#{hostname}-#{uname.machine}-#{uname.sysname}"
    rescue
      "unknown-hwid-#{SecureRandom.hex(8)}"
    end

    def get_pc_user
      ENV['USER'] || ENV['USERNAME'] || 'unknown'
    end

    def generate_webhook_signature(payload)
      "sha256=#{OpenSSL::HMAC.hexdigest('SHA256', @app_secret, payload)}"
    end
  end
end
