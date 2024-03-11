module Resolvers
  class PolicyResolver < Resolvers::BaseResolver
    type Types::PolicyType, null: false

    argument :id, ID, required: true

    def resolve(id:)
      Rails.cache.fetch("policy_#{id}", expires_in: 15.seconds) do
        response = Faraday.get("http://rest_api:3000/policies/#{id}",
                               nil, {'Authorization' => context[:authorization]})
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
