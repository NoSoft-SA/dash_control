# frozen_string_literal: true

namespace :devops do
  desc 'Copy initial files'
  task :copy_initial do
    on roles(:app) do |_|
      execute :echo, "'---' > #{shared_path}/config/dashboards.yml"
      execute :echo, "'---' > #{shared_path}/config/text_contents.yml"
    end
  end
end
