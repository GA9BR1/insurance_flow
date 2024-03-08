module GraphqlRequests
  GRAPHQL_URI = URI('http://graphql_api:3001/graphql').freeze

  def self.query_all_polices(token:)
    query = '{policies{policyId dataEmissao dataFimCobertura segurado {nome cpf} veiculo {marca modelo ano placa}}}'
    response = Net::HTTP.post(GRAPHQL_URI, {query:}.to_json, 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{token}")

    return [] if response.code != '200'

    JSON.parse(response.body)['data']['policies']
  end
end
