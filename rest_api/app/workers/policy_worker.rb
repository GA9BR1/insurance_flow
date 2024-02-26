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
      puts parsed_json
      ActiveRecord::Base.connection_pool.with_connection do
        insured = Insured.create!(parsed_json["insured"])
        vehicle = Vehicle.create!(parsed_json["vehicle"])
        policy = Policy.create!(issue_date: parsed_json["issue_date"], coverage_end: parsed_json["coverage_end"], insured: insured, vehicle: vehicle)
        puts '----------'
        puts policy.id
        puts '---------'
        puts "POLICY CREATED"
        ack!
      end
    rescue StandardError => e
      ack!
      Sneakers.logger.error "Error occurred: #{e.message}"
    end
  end
end
