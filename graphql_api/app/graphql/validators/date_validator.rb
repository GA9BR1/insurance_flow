module Validators
  class DateValidator < Validators::BaseValidator
    def initialize(field:, **default_options)
      @field = field
      super(**default_options)
    end

    def validate(_object, _context, value)
      raise GraphQL::ExecutionError, "Formato de data inválido" if !value.match?(/\d{4}\-\d{2}\-\d{2}/)
        if(@field == "data_emissao")
          raise GraphQL::ExecutionError, "Data de emissão não deve ser futura" if Date.parse(value) > Date.today
        else
          raise GraphQL::ExecutionError, "Data de fim de cobertura deve ser apenas futura" if Date.parse(value) <= Date.today
        end
    end
  end
end
