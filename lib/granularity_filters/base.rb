module GranularityFilters
  class Base
    class FiltersMethodNotCalled < StandardError; end

    def initialize(data)
      @data = data
      @new_data = {}
    end

    def filter
      collect_new_data

      calculate_price_and_return_result
    end

    private

    def collect_new_data
      raise FiltersMethodNotCalled, 'collect_new_data method must be called'
    end

    def calculate_price_and_return_result
      raise FiltersMethodNotCalled, 'calculate_price_and_return_result method must be called'
    end
  end
end
