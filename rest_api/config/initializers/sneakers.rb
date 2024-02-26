Sneakers.configure(
  amqp: "amqp://guest:guest@rabbitmq:5672",
  ack: true,
  log: "/app/log/sneakers.log",
)

Sneakers.logger.level = Logger::INFO
