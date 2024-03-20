module PolicySerializer
  def self.serialize(policy)
    {
        "policy_id": policy.id,
        "data_emissao": policy.issue_date,
        "data_fim_cobertura": policy.coverage_end,
        "valor_premio": policy.prize_value,
        "status": policy.status,
        "link_pagamento": policy.payment_link,
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
