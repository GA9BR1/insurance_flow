Sneakers.configure(
  amqp: "amqp://#{ENV['RABBITMQ_USER']}:#{ENV['RABBITMQ_PASS']}@rabbitmq:5672",
  ack: true,
  log: "/app/log/sneakers.log",
)

Sneakers.logger.level = Logger::INFO
