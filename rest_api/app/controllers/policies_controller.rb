class PoliciesController < ApplicationController
    def index
      limit = params.fetch(:limit, nil)
      policies = Policy.all.order(created_at: :desc).limit(limit)

      render json: policies.map { |policy| PolicySerializer.serialize(policy) }
    end

    def show
        policy = Policy.find_by!(id: params[:id])
        render json: PolicySerializer.serialize(policy)
    end
end
