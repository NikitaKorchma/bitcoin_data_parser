require './lib/granularity_filters/base'

module GranularityFilters
  class Daily < Base
    private

    def collect_new_data
      @data.each do |item|
        @new_data[item['date']] ||= 0
        @new_data[item['date']] += item['price(USD)'].to_f
      end
    end

    def calculate_price_and_return_result
      @new_data.map do |date, total_price|
        [date, total_price]
      end
    end
  end
end
