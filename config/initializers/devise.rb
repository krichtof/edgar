Devise.setup do |config|
  config.mailer_sender = "christophe@merciedgar.com"

  config.mailer.class_eval do
    helper :subdomain
  end

  require 'devise/orm/active_record'

  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email ]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 10
  config.reconfirmable = true
  config.password_length = 8..128
  config.reset_password_within = 6.hours
  config.sign_out_via = Rails.env.test? ? :get : :delete

  config.secret_key = 'a9ceabfa5ecae362a8a0fb0f63e1f642e5b5cce23dd122bdfbdd25ef5436fdb87b45722e19face4a622b3e60be4f7e44fa0fd26c43d2c9459db802964c3a96ca'
  config.allow_insecure_token_lookup = true
end
