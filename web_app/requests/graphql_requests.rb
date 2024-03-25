module GraphqlRequests
  GRAPHQL_URI = URI('http://graphql_api:3001/graphql').freeze

  def self.query_all_polices(token:, token_kind:)
    query = '{policies{policyId dataEmissao dataFimCobertura valorPremio status linkPagamento segurado {nome cpf} veiculo {marca modelo ano placa}}}'
    response = Net::HTTP.post(GRAPHQL_URI, {query:}.to_json, 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{token}", 'Token-Kind' => token_kind)

    return [] if response.code != '200'

    JSON.parse(response.body)['data']['policies']
  end

  def self.mutation_create_policy(token:, token_kind:, params:)
    mutation =
    {
      query: <<-GRAPHQL
        mutation {
          createPolicy(input: {
            policy: {
              dataEmissao: "#{Date.today.to_s}",
              dataFimCobertura: "#{params['end-date']}",
              valorPremio: #{params['prize-value']},
              segurado: {
                nome: "#{params['full-name']}",
                cpf: "#{params['cpf']}",
                email: "#{params['email']}"
              },
              veiculo: {
                marca: "#{params['car-brand']}",
                modelo: "#{params['car-model']}",
                ano: #{params['car-year']},
                placa: "#{params['car-plate']}"
              }
            }
          }) {
            result
          }
        }
      GRAPHQL
    }.to_json
    response = Net::HTTP.post(
    GRAPHQL_URI,
    mutation,
    'Content-Type' => 'application/json',
    'Authorization' => "Bearer #{token}",
    'Token-Kind' => token_kind
    )
    response.body
  end
end
