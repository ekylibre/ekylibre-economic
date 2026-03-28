module Backend
  module Cells
    class EconomicChargesByActivityCellsController < Backend::Cells::BaseController
      def show
        begin
          @title_cel = :economic_charges_by_activity.tl
          @description_cel = :economic_charges_information_1.tl + "\n" + :economic_charges_information_2.tl + "\n"
          @description_cel += :economic_charges_information_3.tl + "\n" + :economic_charges_information_4.tl
          @description_cel = @description_cel.html_safe
          # Getting main activities
          @activities = EconomicIndicator.of_campaign(current_campaign).of_main_product.pluck(:activity_id).map do |act_id|
            Activity.find(act_id)
          end
          @categories = [:structural_loads.tl, :operational_loads.tl, :total_charges.tl, :proportional_products.tl, :direct_products.tl, :total.tl]
          if @activities.any?
            create_series
          else
            @series = []
          end
        rescue
          @series = []
        end
      end

      private

        # Create serie with economics results for a specific campaign
        def create_series
          @series = []
          economic = ActivityEconomic.new(current_campaign)
          @activities.each do |activity|
            result = economic.result_for_variety(activity)
            @series.push({
              name: activity.name,
              data: [
                -result.fixed_direct_charges[:default].to_i - result.activity_indirect_charges[:default].to_i,
                -result.proportional_direct_charges[:default].to_i,
                {isIntermediateSum: true},
                result.proportional_main_product_products[:default].to_i,
                result.fixed_direct_products[:default].to_i,
                {isSum: true}
              ]
            })
          end
        end
    end
  end
end
