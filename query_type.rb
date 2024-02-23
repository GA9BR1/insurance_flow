class QueryType < GraphQL::Schema::Object
    description "The query root of this schema"

    field :policy, resolver: Resolvers::PolicyResolver
end