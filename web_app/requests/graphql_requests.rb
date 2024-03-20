module GraphqlRequests
  GRAPHQL_URI = URI('http://graphql_api:3001/graphql').freeze

  def self.query_all_polices(token:, token_kind:)
    query = '{policies{policyId dataEmissao dataFimCobertura valorPremio status linkPagamento segurado {nome cpf} veiculo {marca modelo ano placa}}}'
    response = Net::HTTP.post(GRAPHQL_URI, {query:}.to_json, 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{token}", 'Token-Kind' => token_kind)

    return [] if response.code != '200'

    JSON.parse(response.body)['data']['policies']
  end
end
