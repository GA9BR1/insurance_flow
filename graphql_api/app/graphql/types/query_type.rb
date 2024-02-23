require 'faraday'
require 'json'

module Types
    class QueryType < Types::BaseObject
      field :policy, Types::PolicyType, null: false do
        argument :id, ID, required: true
      end

      def policy(id:)
        response = Faraday.get("http://rest_api:3000/policies/#{id}")
        JSON.parse(response.body)
      rescue e
        raise GraphQL::ExecutionError, e.message
      end
    end
end
