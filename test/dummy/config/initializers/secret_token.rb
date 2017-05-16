# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
if ::Rails::VERSION::MAJOR < 4
  Dummy::Application.config.secret_token = '362b82703c06793883c00b35de475258c908cc0eadb14390268f1f17e40a60a53af28751de4cababe25abf13b11138051c8311dcdb802f8b581e60e1c24f70af'
else
  Dummy::Application.config.secret_key_base = '362b82703c06793883c00b35de475258c908cc0eadb14390268f1f17e40a60a53af28751de4cababe25abf13b11138051c8311dcdb802f8b581e60e1c24f70af'
end
