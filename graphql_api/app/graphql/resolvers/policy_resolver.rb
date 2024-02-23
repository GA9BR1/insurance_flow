module Resolvers
    class PolicyResolver < BaseResolver
        type Types::PolicyType, null: false
        argument :id, ID, required: true

        def resolve(id:)
            ::Policy.find(id)
        end
    end
end