module Resolvers
  class PolicyResolver < Resolvers::BaseResolver
    type Types::PolicyType, null: false

    argument :id, ID, required: true

    def resolve(id:)
      Rails.cache.fetch("policy_#{id}", expires_in: 1.hour) do
        response = Faraday.get("http://rest_api:3000/policies/#{id}")
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
