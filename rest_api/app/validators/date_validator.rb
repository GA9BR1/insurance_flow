class DateValidator < ActiveModel::Validator
  def validate(record)
    if record.coverage_end <= Date.today
      record.errors[:date] << "only can be in the future"
      raise StandardError, "Coverage end must be in the future"
    end
    if record.issue_date > Date.today
      record.errors[:date] << "can't be in the future"
      raise StandardError, "Issue date can't be in the future"
    end
  end
end
