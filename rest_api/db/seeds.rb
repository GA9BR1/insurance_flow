Insured.create!(name: 'John Doe', cpf: '123.456.789-00')
Vehicle.create!(plate: 'ABC-1234', year: 2022, model: 'Fusca', brand: 'Volkswagen')
Policy.create!(issue_date: '2022-02-22', coverage_end: 1.year.from_now, insured_id: 1, vehicle_id: 1)
