require_relative '../../config/environment'
require_relative '../models/policy.rb'

class PolicyWorker
  include Sneakers::Worker
  from_queue "policy_created"

  def work(msg)
    begin
      puts "---------------"
      puts "MESSAGE RECEIVED"
      puts "---------------"
      parsed_json = JSON.parse(msg)
      assured = Assured.create!(parsed_json["assured"])
      vehicle = Vehicle.create!(parsed_json["vehicle"])
      Policy.create!(issue_date: parsed_json["issue_date"], coverage_end: parsed_json["coverage_end"], assured: assured, vehicle: vehicle)
      puts "POLICY CREATED"
    rescue StandardError => e
      Sneakers.logger.error "Error occurred: #{e.message}"
    end

    ack!
  end
end
