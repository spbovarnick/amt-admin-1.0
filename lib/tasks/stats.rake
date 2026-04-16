task stats: :statsetup

task :statsetup do
  ::STATS_DIRECTORIES.push(
    %w[Serializers app/serializers],
    %w[Webhooks app/webhooks]
  )
end
