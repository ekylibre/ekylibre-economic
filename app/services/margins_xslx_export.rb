# frozen_string_literal: true

class MarginsXslxExport
  include Rails.application.routes.url_helpers
  def generate(activity_ids: nil, campaign_ids: nil)
    if activity_ids.present? && campaign_ids.present?
      eco = ActivityEconomic.new(Campaign.where(id: campaign_ids).first)
      dataset = []
      Activity.where(id: activity_ids).order(:name).each do |activity|
        struct = eco.result_for_variety(activity)
        struct.activity_name = activity.name
        dataset << struct
      end
      generate_ods(dataset)
    end
  end

  private

    def generate_ods(dataset)
      require 'axlsx'
      p = Axlsx::Package.new
      wb = p.workbook

      s = wb.styles
      header_style = s.add_style sz: 12, b: true, alignment: { horizontal: :center }, font_name: 'Arial'
      row_style = s.add_style sz: 10, alignment: { horizontal: :center }, font_name: 'Arial'
      formula_style = s.add_style sz: 11, b: true, alignment: { horizontal: :center }, font_name: 'Arial'
      legal_ratio_style = s.add_style bg_color: '43AAFF', type: :dxf
      total_cost_ratio_style = s.add_style sz: 10, b: true, alignment: { horizontal: :center }, bg_color: 'FFAC43', type: :dxf
      date_style = s.add_style format_code: 'dd/mm/yyyy'
      # autorized_style = s.add_style bg_color: '00ff04', type: :dxf

      clean_dataset = []
      puts dataset.inspect.red
      clean_dataset << ["Activité"] + dataset.pluck(:activity_name)
      clean_dataset << ["Surface / Tête"] + dataset.pluck(:total_area)
      clean_dataset << ["Produit principal"] + dataset.pluck(:main_product_name)
      dataset.pluck(:yield).each{|y| y["human_yield"] = y["default"].to_s + " "+  y["unit"].to_s}
      clean_dataset << ["Rendement"] + dataset.map{|i| i[:yield][:human_yield]}
      clean_dataset << ["CA produit principal"] + dataset.map{|i| i[:proportional_main_product_products][:default]}
      clean_dataset << ["CA autres produits"] + dataset.map{|i| i[:fixed_direct_products][:default]}
      clean_dataset << ["Charges proportionnelles directes"] + dataset.map{|i| i[:proportional_direct_charges][:default]}
      clean_dataset << ["Charges fixes directes"] + dataset.map{|i| i[:fixed_direct_charges][:default]}
      clean_dataset << ["Marge brute"] + dataset.map{|i| i[:gross_margin][:default]}
      clean_dataset << [:activity_indirect_products.tl] + dataset.map{|i| i[:activity_indirect_products][:default]}
      clean_dataset << [:activity_indirect_charges.tl] + dataset.map{|i| i[:activity_indirect_charges][:default]}
      clean_dataset << [:activity_employees_wages.tl] + dataset.map{|i| i[:activity_employees_wages][:default]}
      clean_dataset << [:activity_depreciations_charges.tl] + dataset.map{|i| i[:activity_depreciations_charges][:default]}
      clean_dataset << [:activity_loans_charges.tl] + dataset.map{|i| i[:activity_loans_charges][:default]}
      clean_dataset << [:activity_farmer_wages.tl] + dataset.map{|i| i[:activity_farmer_wages][:default]}
      clean_dataset << [:production_cost.tl] + dataset.map{|i| i[:production_cost][:default]}
      clean_dataset << [:net_margin.tl] + dataset.map{|i| i[:net_margin][:default]}
      puts clean_dataset.inspect.yellow

      wb.add_worksheet(name: :margins_indicators.tl) do |sheet|
        # add lines
        clean_dataset.each_with_index do |item, index|
          if index == 0
            sheet.add_row item, style: [header_style] * item.count
          elsif (index == 8 || index == 15 || index == 16)
            sheet.add_row item, style: [formula_style] * item.count
          else
            sheet.add_row item, style: [row_style] * item.count
          end
        end
      end

      p.use_shared_strings = true
      p.to_stream
    end
end
