class String
  def ogrn?
    match?(/^\d{13}$/)
  end

  def ogrnip?
    match?(/^\d{15}$/)
  end

  def person_inn?
    return false unless match?(/^((?!0)\d{11}|(?!00)\d{12})$/)

    digits = identifier_to_digits(12)
    indexes_1 = [7, 2, 4, 10, 3, 5, 9, 4, 6, 8, 0]
    indexes_2 = [3] + indexes_1

    valid_inn_checksum?(digits, indexes_1, 10) && valid_inn_checksum?(digits, indexes_2, 11)
  end

  def company_inn?
    return false unless match?(/^((?!0)\d{9}|(?!00)\d{10})$/)

    digits = identifier_to_digits(10)
    indexes = [2, 4, 10, 3, 5, 9, 4, 6, 8, 0]

    valid_inn_checksum?(digits, indexes, 9)
  end

  private

  def valid_inn_checksum?(digits = [], indexes = [], index)
    check_numbers = digits.map.with_index { |item, index| item * indexes[index].to_i }
    check_number = check_numbers.sum % 11
    check_number = check_number % 10 if check_number > 9
    check_number == digits[index]
  end

  def identifier_to_digits(size)
    digits = to_i.digits.reverse
    digits.size < size ? digits.unshift(0) : digits
  end
end
