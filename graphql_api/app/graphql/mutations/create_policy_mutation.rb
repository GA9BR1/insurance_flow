module Mutations
  class CreatePolicyMutation < Mutations::BaseMutation
    argument :policy, Types::PolicyInputType, required: true

    field :result, String, null: false

    def resolve(policy:)
      conn = Bunny.new(hostname: "rabbitmq", username: ENV['RABBITMQ_USER'], password: ENV['RABBITMQ_PASS']).start
      ch = conn.create_channel
      queue = ch.queue("policy_created", durable: true)
      queue.publish(parse_policy(policy.to_h))
      conn.close
      {"result" => "OK"}
    rescue StandardError => e
      raise GraphQL::ExecutionError, e.message
    end

    private
    def parse_policy(policy)
      {
        issue_date: policy[:data_emissao],
        coverage_end: policy[:data_fim_cobertura],
        prize_value: policy[:valor_premio],
        insured: {
          name: policy[:segurado][:nome],
          cpf: policy[:segurado][:cpf],
          email: policy[:segurado][:email]
        },
        vehicle: {
          brand: policy[:veiculo][:marca],
          model: policy[:veiculo][:modelo],
          year: policy[:veiculo][:ano],
          plate: policy[:veiculo][:placa]
        }
      }.to_json
    end
  end
end
