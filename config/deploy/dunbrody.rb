# frozen_string_literal: true

# Unifrutti Dunbrody
set :chruby_ruby, 'ruby-2.5.1'
server '172.17.2.90', user: 'nspack', roles: %w[app db web]
set :deploy_to, '/home/nspack/dashboards'
