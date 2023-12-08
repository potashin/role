class ApplicationQuery
  include Filterable
  include Sortable

  class << self
    def call(...)
      new(...).call
    end
  end

  def initialize(filters: {}, sorting: {})
    self.sorting = sorting
    self.filters = filters
  end

  def call
    Flows::Compose.new(
      method(:build_relation),
      method(:sort)
    ).call
  end

  def build_relation
    raise NotImplementedError
  end
end
