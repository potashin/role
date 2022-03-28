module Role
  class IdentificatorValidator < ActiveModel::Validator
    def validate(record)
      if record.entity_id.blank?
        record.errors.add(:entity_id, :blank)
      elsif record.person? && !person_id?(record.entity_id)
        record.errors.add(:entity_id, "Person ID is not a valid OGRNIP/INN")
      elsif record.company? && !company_id?(record.entity_id)
        record.errors.add(:entity_id, "Company ID is not a valid OGRN/INN")
      end
    end

    private

    def person_id?(entity_id)
      ogrnip?(entity_id) || person_inn?(entity_id)
    end

    def company_id?(entity_id)
      ogrn?(entity_id) || company_inn?(entity_id)
    end

    def ogrn?(str)
      str.match?(/^\d{13}$/) && valid_ogrn_checksum?(str)
    end

    def ogrnip?(str)
      str.match?(/^\d{15}$/) && valid_ogrn_checksum?(str)
    end

    def person_inn?(str)
      return false unless str.match?(/^((?!0)\d{11}|(?!00)\d{12})$/)

      digits = identifier_to_digits(str, 12)
      indexes_1 = [7, 2, 4, 10, 3, 5, 9, 4, 6, 8, 0]
      indexes_2 = [3] + indexes_1

      valid_inn_checksum?(digits, indexes_1, 10) && valid_inn_checksum?(digits, indexes_2, 11)
    end

    def company_inn?(str)
      return false unless str.match?(/^((?!0)\d{9}|(?!00)\d{10})$/)

      digits = identifier_to_digits(str, 10)
      indexes = [2, 4, 10, 3, 5, 9, 4, 6, 8, 0]

      valid_inn_checksum?(digits, indexes, 9)
    end

    private

    def valid_ogrn_checksum?(str)
      (str[0..(str.size - 2)].to_i % (str.size - 2)).to_s[-1] == str[-1]
    end

    def valid_inn_checksum?(digits = [], indexes = [], index)
      check_numbers = digits.map.with_index { |item, index| item * indexes[index].to_i }
      check_number = check_numbers.sum % 11
      check_number = check_number % 10 if check_number > 9
      check_number == digits[index]
    end

    def identifier_to_digits(str, size)
      digits = str.to_i.digits.reverse
      digits.size < str.size ? digits.unshift(0) : digits
    end
  end
end
