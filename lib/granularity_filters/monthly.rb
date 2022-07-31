require './lib/granularity_filters/base'

module GranularityFilters
  class Monthly < Base
    private

    def collect_new_data
      @data.each do |item|
        date = Date.parse(item['date'])
        start_of_month = Date.new(date.year, date.month, 1)

        @new_data[start_of_month.to_s] ||= 0
        @new_data[start_of_month.to_s] += item['price(USD)'].to_f
      end
    end

    def calculate_price_and_return_result
      @new_data.map do |date, total_price|
        first_day_in_month = Date.parse(date)
        days_in_month = (first_day_in_month.next_month - 1).day
        average_price = (total_price / days_in_month).round(2)

        [first_day_in_month.to_s, average_price]
      end
    end
  end
end
