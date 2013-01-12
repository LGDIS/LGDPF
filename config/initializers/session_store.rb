# Be sure to restart your server when you modify this file.

LGDPF::Application.config.session_store :cookie_store, key: '_LGDPF_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# LGDPF::Application.config.session_store :active_record_store

# To use Dalli memcached client library for Rails Session Storage.
# LGDPF::Application.config.session_store ActionDispatch::Session::CacheStore, :expire_after => 20.minutes
