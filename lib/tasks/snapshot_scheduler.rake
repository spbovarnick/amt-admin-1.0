desc "This task is called by the Heroku scheduler add-on and sends a weekly CSV snapshot of the entire archive"

require 'csv'

task :send_snapshot => :environment do
  if Time.now.monday?
    WeeklyCsvSnapshotJob.perform_later
  end
end