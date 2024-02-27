require 'faraday'
require 'json'

module Types
    class QueryType < Types::BaseObject
      field :policy, resolver: Resolvers::PolicyResolver
      field :policies, resolver: Resolvers::PoliciesResolver
    end
end
