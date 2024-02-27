module Resolvers
  class PoliciesResolver < Resolvers::BaseResolver
    type [Types::PolicyType], null: false

    argument :last_ones, Integer, required: false

    def resolve(last_ones: "no_limit")
      Rails.cache.fetch("policies_limit=#{last_ones}", expires_in: 1.hour) do
        response = Faraday.get("http://rest_api:3000/policies#{last_ones == "no_limit" ? "" : "?limit=#{last_ones}"}")
        if(response.status != 200)
          raise StandardError, "Erro ao buscar as polices: #{response.status}"
        end
        JSON.parse(response.body)
      end
    rescue StandardError => e
      raise GraphQL::ExecutionError, e.message
    end
  end
end
