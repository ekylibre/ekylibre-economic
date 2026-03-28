module Economic
  class CostsController < Backend::BaseController

    def show
      eco = ActivityEconomic.new(current_campaign)
      computed_activity_ids = EconomicIndicator.of_campaign(current_campaign).of_main_product.pluck(:activity_id)
      activities = Activity.availables.main.where(id: computed_activity_ids).reorder(:name)
      excluded_activities = activities.without_production_dates
      if excluded_activities.any?
        notify_warning_now(:activities_excluded_because_of_production_dates.tl(activity_names: excluded_activities.pluck(:name).join(', ')))
      end
      included_activities = activities.with_production_dates
      if included_activities.any?
        @activities_by_families = included_activities.group_by(&:family).transform_values do |activities|
          activities.map!{ |activity|  {activity: activity, result:  eco.result_for_variety(activity)}.to_struct }
        end
      end
    end

    # def traceability_xslx_export
    #  return unless @cost = find_and_check

    #  campaigns = Campaign.where(id: params[:campaign_id])
    #  InterventionExportJob.perform_later(activity_id: @activity_cost_output.activity.id, campaign_ids: campaigns.pluck(:id), user: current_user)
    #  notify_success(:document_in_preparation)
    #  redirect_to economic_cost_path( @activity_cost_output)
    # end

    #def global_costs_xslx_export
    #  return unless @activity_cost_output = find_and_check

    #  campaigns = Campaign.where(id: params[:campaign_id])
    #  GlobalCostExportJob.perform_later(activity_id: @activity_cost_output.activity.id, campaign_ids: campaigns.pluck(:id), user: current_user)
    #  notify_success(:document_in_preparation)
    #  redirect_to economic_cost_path( @activity_cost_output)
    # end

  end
end
