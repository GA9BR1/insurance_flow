require 'bunny'
require 'json'

conn = Bunny.new(hostname: 'localhost').start
ch = conn.create_channel
ch.confirm_select

# declare a queue
q  = ch.queue("policy_created", durable: true)
q.subscribe(manual_ack: true) do |delivery_info, metadata, payload|
  puts "This is the message: #{payload}"
  # acknowledge the delivery so that RabbitMQ can mark it for deletion
  ch.ack(delivery_info.delivery_tag)
end

# publish a message to the default exchange which then gets routed to this queue
q.publish(
  {
    issue_date: "2021-01-01",
    coverage_end: "2021-12-31",
    insured: {
      name: "Fulano de Tal",
      cpf: "123.456.789-00"
    },
    vehicle: {
      brand: "Volkswagen",
      model: "Gol",
      year: 2010,
      plate: "ABC-1234"
    }
  }.to_json
)

# await confirmations from RabbitMQ, see
# https://www.rabbitmq.com/publishers.html#data-safety for details
ch.wait_for_confirms

# give the above consumer some time consume the delivery and print out the message
sleep 1

puts "Done"

ch.close
# close the connection
conn.close
