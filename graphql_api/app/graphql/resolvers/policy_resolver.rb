module Resolvers
  class PolicyResolver < Resolvers::BaseResolver
    type Types::PolicyType, null: false

    argument :id, ID, required: true

    def resolve(id:)
      response = Faraday.get("http://rest_api:3000/policies/#{id}")
      JSON.parse(response.body)
    rescue StandardError => e
      raise GraphQL::ExecutionError, e.message
    end
  end
end
