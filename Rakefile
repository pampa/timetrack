require_relative "./config"

namespace :db do
  desc "migrate"
  task :migrate do
    require 'fileutils'
    FileUtils.mkdir_p($data_path)
    system "bundle exec sequel -E -m ./migrations #{$db_uri}"
  end

  task :rollback do
    schema_version = `bundle exec sequel -c "puts DB[:schema_info].first[:version]" #{$db_uri}`.to_i
    system "bundle exec sequel -E -m ./migrations -M #{schema_version - 1} #{$db_uri}"
  end

end
