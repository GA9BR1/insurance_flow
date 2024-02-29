module Validators
  class DateValidator < Validators::BaseValidator
    def validate(_object, _context, value)
      raise GraphQL::ExecutionError, "Invalid date format" if !value.match?(/\d{4}\-\d{2}\-\d{2}/)
      raise GraphQL::ExecutionError, "Dates should not be in the future" if Date.parse(value) > Date.today
    end
  end
end
