# frozen_string_literal: true

# Unifrutti Dunbrody
server '172.17.2.90', user: 'nsld', roles: %w[app db web]
set :deploy_to, '/home/nsld/dashboards'
