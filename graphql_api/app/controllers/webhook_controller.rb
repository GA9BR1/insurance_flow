class WebhookController < ApplicationController
  def update
    payload = request.body.read
    event = Stripe::Event.construct_from(
      JSON.parse(payload, symbolize_names: true)
    )
    case event.type
    when 'checkout.session.completed'
      object = event.data.object
      conn = Bunny.new(hostname: "rabbitmq", username: ENV['RABBITMQ_USER'], password: ENV['RABBITMQ_PASS']).start
      ch = conn.create_channel
      queue = ch.queue("policy_payment", durable: true)
      queue.publish(object['metadata']['policy_id'])
      conn.close
    end
  end
end
