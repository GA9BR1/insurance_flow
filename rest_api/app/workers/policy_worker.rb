require_relative '../../config/environment'
require_relative '../models/policy.rb'
require 'bunny'

class PolicyWorker
  include Sneakers::Worker
  from_queue "policy_created"

  def work(msg)
    parsed_json = JSON.parse(msg)
    puts parsed_json
    ActiveRecord::Base.connection_pool.with_connection do
      ActiveRecord::Base.transaction do
        policy = create_policy(parsed_json)
        policy.update!(payment_link: generate_payment_link(policy, parsed_json).url)
        send_policy_creation_websockets_message(policy)
      rescue StandardError => e
        send_policy_creation_error_websockets_message(e)
        Stripe::PaymentLink.retrieve(response_payment.id)
        handle_error(msg, e)
      end
    end
    ack!
  end

  private

  def create_policy(parsed_json)
    insured = Insured.find_or_create_by!(parsed_json["insured"])
    vehicle = Vehicle.create!(parsed_json["vehicle"])
    Policy.create!(issue_date: parsed_json["issue_date"], coverage_end: parsed_json["coverage_end"],
                            prize_value: parsed_json["prize_value"], insured:, vehicle:)
  end

  def send_policy_creation_websockets_message(policy)
    Net::HTTP.post(URI('http://web_app:3000/send_to_websockets'),
      {"type" => "policy_created", "policy" => PolicySerializer.serialize(policy)}.to_json,
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{JWT.encode({id: SecureRandom.uuid}, ENV['JWT_SECRET'], 'HS256')}"
      )
  end

  def send_policy_creation_error_websockets_message(error)
    response = Net::HTTP.post(URI('http://web_app:3000/send_to_websockets'),
        {"type" => "policy_creation_error", "message" => error}.to_json,

          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{JWT.encode({id: SecureRandom.uuid}, ENV['JWT_SECRET'], 'HS256')}"
        )
  end

  def generate_payment_link(policy, parsed_json)
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    response = Stripe::Price.create({
      currency: 'brl',
      unit_amount: parsed_json['prize_value'].to_i * 100,
      product_data: { name: 'Seguro' },
    })
    Stripe::PaymentLink.create({
      line_items: [
        {
          price: response.id,
          quantity: 1,
        },
      ],
      metadata: {
        policy_id: policy.id
      }
    })
  end

  def handle_error(msg, error)
    error_message = {
      error: error.message,
      original_message: msg
    }

    puts error_message

    begin
      conn = Bunny.new(hostname: "rabbitmq", username: ENV['RABBITMQ_USER'], password: ENV['RABBITMQ_PASS']).start
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
