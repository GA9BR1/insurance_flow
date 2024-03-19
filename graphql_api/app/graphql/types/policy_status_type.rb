module Types
  class PolicyStatusType < GraphQL::Schema::Enum
    value "emited"
    value "waiting_payment"
    value "canceled"
  end
end
