require './lib/granularity_filters/base'

module GranularityFilters
  class Quarterly < Base
    private

    def collect_new_data
      @data.each do |item|
        date = Date.parse(item['date'])
        month = 1 if date.month < 4
        month = 4 if date.month >= 4 && date.month < 7
        month = 7 if date.month >= 7 && date.month < 10
        month = 10 if date.month >= 10
        start_of_quarter = Date.new(date.year, month, 1)

        @new_data[start_of_quarter.to_s] ||= 0
        @new_data[start_of_quarter.to_s] += item['price(USD)'].to_f
      end
    end

    def calculate_price
      @new_data.map do |date, total_price|
        first_day_in_quarter = Date.parse(date)
        next_quarter_month = first_day_in_quarter.month == 10 ? 1 : first_day_in_quarter.month + 3
        next_quarter_year = first_day_in_quarter.month == 10 ? first_day_in_quarter.year + 1 : first_day_in_quarter.year
        first_day_in_next_quarter = Date.new(next_quarter_year, next_quarter_month, 1)
        days_in_quarter = (first_day_in_next_quarter - first_day_in_quarter).to_i
        average_price = (total_price / days_in_quarter).round(2)

        [first_day_in_quarter.to_s, average_price]
      end
    end
  end
end
