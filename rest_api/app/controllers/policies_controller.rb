class PoliciesController < ApplicationController
    def show
        policy = Policy.find_by(id: params[:id])
        render json: success(policy)
    end

    private

    def success(policy)
        { 
            "policy_id": policy.id,
            "data_emissao": policy.issue_date,
            "data_fim_cobertura": policy.coverage_end,
            "segurado": {
                "nome": policy.assured.name,
                "cpf": policy.assured.cpf,
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
