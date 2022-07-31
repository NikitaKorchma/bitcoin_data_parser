require './lib/granularity_filters/base'

module GranularityFilters
  class Weekly < Base
    DAYS_IN_WEEK = 7

    private

    def collect_new_data
      @data.each do |item|
        date = Date.parse(item['date'])
        start_of_week = date - (date.wday - 1) % 7

        @new_data[start_of_week.to_s] ||= 0
        @new_data[start_of_week.to_s] += item['price(USD)'].to_f
      end
    end

    def calculate_price
      @new_data.map do |date, total_price|
        average_price = (total_price / DAYS_IN_WEEK).round(2)

        [date, average_price]
      end
    end
  end
end
