# Insurance Flow

<img src="https://user-images.githubusercontent.com/25181517/192107856-aa92c8b1-b615-47c3-9141-ed0d29a90239.png" width="50"/> <img src="https://user-images.githubusercontent.com/25181517/192603748-3ac17112-3653-4257-80da-a57334b11411.png" width="50"/> <img src="https://github.com/marwin1991/profile-technology-icons/assets/136815194/50342602-8025-4030-b492-550f2eaa4073" width="50"/> <img src="https://user-images.githubusercontent.com/25181517/117207330-263ba280-adf4-11eb-9b97-0ac5b40bc3be.png" width="50"/> <img src="https://jondot.github.io/sneakers/images/main_logo.png" width="50"/> <img src="https://user-images.githubusercontent.com/25181517/117208740-bfb78400-adf5-11eb-97bb-09072b6bedfc.png" width="50"/>

O Insurance Flow é um projeto que simula o "flow" da criação de uma apólice de seguro. O projeto utiliza tecnologias comumente utilizadas na seguradora Youse.

## Tecnologias
- GraphQL
- Ruby On Rails
- RabbitMQ
- Docker
- Sneakers
- Postgres

## Como rodar o projeto?

Basta ter o Docker instalado e rodar o comando:
```
docker compose up
```

## Funcionamento

#### API GraphQL: É a api responsável por gerenciar as requisições feitas pelo usuário, através dele são feitas algumas validações de tipos e também faz o envio de mensagem ou requisição para a API Rest.
#### API Rest: É a api responsável por armazenar os dados das apólices, servir e processar os dados das mesmas.

Fluxo:
- Query -> Usuário faz uma query pedindo dados de uma apólice com id x -> GraphQL recebe a requisição, e envia uma requisição para a endpoint de get de uma apólice por id -> API Rest devolve a apólice para a API GraphQL -> API GraphQL devolve a resposta da maneira preferida pelo usuário.
- Mutation -> Usuário faz uma query do tipo mutation enviando dados para a criação de uma apólice -> GraphQL recebe a requisição, e envia uma mensagem para uma fila do RabbitMQ chamada policy_created -> GraphQL devolve uma mensagem falando que tá tudo Ok -> Sneakers consume essa mensagem realizando a tarefa de tentar criar a apólice no banco de dados (na API Rest) -> Caso dê errado é publicado uma mensagem no mesmo RabbitMQ na fila de policy_error e caso dê certo mais nada é feito.

## Endpoint e Querys GraphQl

O endpoint do GraphQl é **localhost:3001/graphql - POST**

#### Mutation

Cria uma apólice na Api Rest. 
Esse é um processo assíncrono, portanto um retorno OK por parte da Api do GraphQL não garante que a apólice foi criada.
```
mutation {
  createPolicy(input:{
		policy: {
      dataEmissao: "2019-03-12",
      dataFimCobertura: "2020-05-12",
      segurado: {
        nome: "João Paulo",
        cpf: "737.196.050-51"
      },
      veiculo: {
        marca: "BMW",
        modelo: "M1",
        ano: 2015,
        placa: "XRE-2380"
      }
    }
  }) {
    result
  }
}
```
#### Queries

Busca por uma apólice com id específico.
```
{
    policy(id: 2){
        policyId
        dataEmissao
        dataFimCobertura
        segurado {
            nome
            cpf
        }
        veiculo {
            marca
            modelo
            ano
            placa
        }
    }
}
```


Busca pelas ultimas N apólices, se nenhuma for passada buscará todas.
```
{
    policies(lastOnes: 10){
    	policyId
        dataEmissao
        dataFimCobertura
        segurado {
            nome
            cpf
        }
        veiculo {
            marca
            modelo
            ano
            placa
        }
  }
}
```

