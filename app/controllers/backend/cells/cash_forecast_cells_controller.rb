module Backend
  module Cells
    class CashForecastCellsController < Backend::Cells::BaseController
      include ChartsHelper

      def show
        @title_cel = :cash_forecast_cell_title.tl
        @description_cel = :cash_forecast_cell_line_1.tl + "\n" + :cash_forecast_cell_line_2.tl + "\n"
        @description_cel += :cash_forecast_cell_line_3.tl + "\n" + :cash_forecast_cell_line_4.tl
        @campaign = current_campaign
        # items = EconomicCashIndicator.of_campaign(@campaign).reorder(:used_on)
        # @fy = current_financial_year
        stopped_on = Date.new(@campaign.harvest_year, 12, 31)
        started_on = Date.new(@campaign.harvest_year, 1, 1)
        items = EconomicCashIndicator.used_between(started_on, stopped_on).reorder(:used_on)
        budgets = items.pluck(:context).uniq
        @series = []
        @drilldown = {}
        @drilldown[:series] = []
        @title = "#{started_on.l} - #{stopped_on.l}"
        if items.any?
          @categories = first_day_of_months_between(started_on, stopped_on)

          # build global balance for all items
          balance_data = []
          balance_collection = items.group_by { |item| item.used_on.beginning_of_month.to_date }
          month_balance = 0.0
          @categories.each do |categorie|
            balance_items = balance_collection.select{ |k, v| k == categorie}
            if balance_items.any?
              month_expense_balance = balance_items.values.flatten.select{ |n| n.direction == 'expense'}.sum(&:amount)
              month_revenue_balance = balance_items.values.flatten.select{ |n| n.direction == 'revenue'}.sum(&:amount)
              month_balance += (month_revenue_balance - month_expense_balance).round(2)
            end
            balance_data << month_balance.to_s.to_f
          end
          @series << { type: 'spline', name: :balance.tl, data: balance_data, marker: {line_width: 2} }

          @categories.each do |category|
            month_dataset = items.used_between(category.beginning_of_month, category.end_of_month).reorder(:used_on)
            @drilldown[:series] << build_data_drilldown(category, month_dataset)
          end

          # build revenue & expenses by month for each context (activities, worker_contract, loan)
          budgets.each do |budget|
            color = items.of_context(budget).first.context_color
            # expense_dataset = items.of_context(budget).expenses.reorder(:used_on)
            # revenue_dataset = items.of_context(budget).revenues.reorder(:used_on)
            dataset = items.of_context(budget).reorder(:used_on)

            # @series << create_serie_for(expense_dataset, @categories, budget, -1.0, 'expense', color) if expense_dataset.any?
            # @series << create_serie_for(revenue_dataset, @categories, budget, 1.0, 'revenue', color) if revenue_dataset.any?
            @series << create_serie_for(dataset, @categories, budget, 1.0, nil, color) if dataset.any?
          end
        end
        @drilldown
        @series
      end

      private

        def create_serie_for(collection, categories, name, coefficient = 1.0, direction = nil, color)
          coefficient = -1.0 if direction == 'expense'
          grouped_collection = collection.group_by { |item| item.used_on.beginning_of_month.to_date }
          # data = grouped_collection.map { |k, v| [k, v.map{ |i| ( i.direction == 'expense' ? i.amount * -1 : i.amount)}.compact.sum(&:amount) ]}.sort.to_h
          data = grouped_collection.map { |k, v| [k, v.map{ |i| (i.direction == 'expense' ? (i.amount * -1.0) : i.amount)}.compact.sum]}.sort.to_h
          chart_data = fill_values categories, data, name, empty_value: nil

          { type: 'column', name: name, data: chart_data, color: color} # stack: direction
        end

        def first_day_of_months_between(started_on, stopped_on)
          res = started_on.beginning_of_month
          categories = []

          while res < stopped_on
            categories << res
            res += 1.month
          end

          categories
        end

        def fill_values(categories, values, name, empty_value:)
          categories.map do |date|
            { name: name, y: values.fetch(date, empty_value).to_f.round(2), drilldown: date.to_s }
          end
        end

        def build_data_drilldown(category, dataset)
          data = []
          dataset.each do |item|
            if item[:direction] == 'expense'
              # y = -1.0
              color = :red
            else
              # y = 1.0
              color = :green
            end
            data <<  { name: item[:context], data_labels: { format: '{point.name}' }, value: item[:amount].to_s.to_f, color: color }
          end
          # data <<  { name: :balance.tl, isSum: true, color: :blue }
          # { id: category.to_s, type: 'waterfall', data: data }

          { id: category.to_s, type: 'packedbubble', data: data }

        end
    end
  end
end
