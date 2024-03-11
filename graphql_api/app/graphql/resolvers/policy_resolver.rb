module Resolvers
  class PolicyResolver < Resolvers::BaseResolver
    type Types::PolicyType, null: false

    argument :id, ID, required: true

    def resolve(_obj, args, context)
      Rails.logger.info("Resolvendo a política para o ID: #{context}")
      Rails.logger.info("333333333333333333333333333")
      Rails.cache.fetch("policy_#{args[:id]}", expires_in: 15.seconds) do
        response = Faraday.get("http://rest_api:3000/policies/#{args[:id]}", nil, {'Authorization' => "Bearer " + context})
        if(response.status != 200)
          raise StandardError, "Erro ao buscar a policy: #{response.status}"
        end
        JSON.parse(response.body)
      end
    rescue StandardError => e
      raise GraphQL::ExecutionError, e.message
    end
  end
end
