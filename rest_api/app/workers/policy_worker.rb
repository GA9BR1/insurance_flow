require_relative '../../config/environment'
require_relative '../models/policy.rb'
require 'bunny'

class PolicyWorker
  include Sneakers::Worker
  from_queue "policy_created"

  def work(msg)
    begin
      parsed_json = JSON.parse(msg)
      puts parsed_json
      ActiveRecord::Base.connection_pool.with_connection do
        ActiveRecord::Base.transaction do
          insured = Insured.find_or_create_by!(parsed_json["insured"])
          vehicle = Vehicle.create!(parsed_json["vehicle"])
          policy = Policy.create!(issue_date: parsed_json["issue_date"], coverage_end: parsed_json["coverage_end"], insured:, vehicle:)
        end
      end
    rescue StandardError => e
      puts "PolicyWorker ERROR: #{e.message}"
      Sneakers.logger.error "Error occurred: #{e.message}"
      handle_error(msg, e)
    end
    ack!
  end

  private

  def handle_error(msg, error)
    error_message = {
      error: error.message,
      original_message: msg
    }

    puts error_message

    begin
      conn = Bunny.new(hostname: "rabbitmq").start
      ch = conn.create_channel
      q  = ch.queue("policy_error", durable: true)
      q.publish(error_message.to_json)
      conn.close
      puts "Error message published to policy_error queue"
    rescue StandardError => e
      puts "Error publishing error message: #{e.message}"
      Sneakers.logger.error "Error publishing error message: #{e.message}"
    end
  end
end
