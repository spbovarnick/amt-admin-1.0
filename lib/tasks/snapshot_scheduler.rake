desc "This task is called by the Heroku scheduler add-on and sends a weekly CSV snapshot of the entire archive"

task :send_snapshot do
  WeeklyCsvSnapshotJob.perform_later
end