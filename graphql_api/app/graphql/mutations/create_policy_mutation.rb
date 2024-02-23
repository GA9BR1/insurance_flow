module Mutations
  class CreatePolicyMutation < Mutations::BaseMutation
    argument :policy, Types::PolicyInputType, required: true

    field :policy, Types::PolicyType, null: false
    field :errors, [String], null: false

    def resolve(policy:)
      {policy: policy, errors: []}
    end
  end
end
