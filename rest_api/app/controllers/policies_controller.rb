class PoliciesController < ApplicationController
    def index
      limit = params.fetch(:limit, nil)
      policies = Policy.all.limit(limit)

      render json: policies.map { |policy| success(policy) }
    end

    def show
        policy = Policy.find_by!(id: params[:id])
        render json: success(policy)
    end

    private

    def success(policy)
        {
            "policy_id": policy.id,
            "data_emissao": policy.issue_date,
            "data_fim_cobertura": policy.coverage_end,
            "valor_premio": policy.prize_value,
            "status": policy.status,
            "segurado": {
                "nome": policy.insured.name,
                "cpf": policy.insured.cpf,
                "email": policy.insured.email,
            },
            "veiculo": {
                "marca": policy.vehicle.brand,
                "modelo": policy.vehicle.model,
                "ano": policy.vehicle.year,
                "placa": policy.vehicle.plate
            }
        }
    end
end
