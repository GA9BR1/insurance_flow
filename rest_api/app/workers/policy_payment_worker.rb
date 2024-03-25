require_relative '../../config/environment'
require_relative '../models/policy.rb'

class PolicyPaymentWorker
  include Sneakers::Worker
  from_queue "policy_payment"

  def work(policy_id)
    ActiveRecord::Base.connection_pool.with_connection do
      Policy.find(policy_id).update(status: 'emited')
      response = Net::HTTP.post(URI('http://web_app:3000/send_to_websockets'),
        {"type" => "policy_payment", "policy_id" => policy_id}.to_json,

          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{JWT.encode({id: SecureRandom.uuid}, ENV['JWT_SECRET'], 'HS256')}"
        )
    end

    ack!
  end
end
