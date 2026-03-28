class ActivityEconomic

  class << self

    def format_n(chars)
      if chars.is_a?(String)
        number = chars.match(/-?\d{1,10}([\,\.]{1}\d{1,10})?/)[0]
        chars[number] = ''
        remain = chars
      else
        number = chars
        remain = ''
      end
      if number.to_f.abs >= 100
        "#{number.to_i.to_s.reverse.gsub(/...(?=.)/, '\& ').reverse}#{remain}"
      else
        "#{'%.2f' % number.to_f}#{remain}"
      end
    end

  end

  def initialize(campaign)
    @campaign = campaign
    @currency = Onoma::Currency.find(Preference[:currency]).symbol
    EconomicIndicator.refresh # refresh view
  end

  def indirect_charges
    # method  EconomicIndicator.indirect_exploitation_charges_simulator(@campaign)
    # params Campaign::Object
    # return Hash to_struct
    ## Worker Charge from WorkerContract
    # items[:annual_farmer_wages]
    # items[:annual_employees_wages]
    ## Charges & Products coming from auxiliary activity
    # items[:annual_fixed_charges]
    # items[:annual_fixed_products]
    ## FixedAssetDepreciations & LoanRepayment already set
    # items[:annual_depreciations_charges]
    # items[:annual_loans_charges]
    ## Provisions : 0 by default
    # items[:annual_cash_provisions]
    # items[:currency]
    call = EconomicIndicator.indirect_exploitation_charges_simulator(@campaign)
  end

  def result_for_variety(activity)
    call = view_call(activity)
    compute_variety_result(call).to_struct
  end

  private

    def view_call(activity)
      # method  EconomicIndicator.activity_simulator(activity, @campaign)
      # params Campaign::Object, Activity::Object
      # return Hash
      # items[:total_area] ex : 25,75
      # items[:area_unit] ex : hectare
      # items[:main_product_yield] ex : 75,12
      # items[:main_product_yield_unit_id] ex : id in model Unit
      ### PLANNED
      ## Main & Others Direct Activity Products
      # items[:proportional_main_product_products] ex : 32561,25 (€)
      # items[:fixed_direct_products] ex : 1562,12 (€)
      ## Proportionnal & Fixed  Direct Activity Charges
      # items[:proportional_direct_charges] ex : 5825,12 (€)
      # items[:fixed_direct_charges] ex : 1526,52 (€)
      # items[:gross_margin] ex : 21523,23 (€)
      ## Fixed Indirect Activity Charges
      # items[:activity_indirect_products] ex : { activity_value: 2536 , activity_ratio: 0.23}ALREADY COMPUTED AND PONDERATED WITH repartition_key
      # items[:activity_indirect_charges] = { activity_value: 8965 , activity_ratio: 0.23} ALREADY COMPUTED AND PONDERATED WITH repartition_key
      # items[:activity_employees_wages] = { activity_value: 2563 , activity_ratio: 0.23} ALREADY COMPUTED AND PONDERATED WITH repartition_key
      # items[:activity_depreciations_charges] = { activity_value: 8563 , activity_ratio: 0.23} ALREADY COMPUTED AND PONDERATED WITH repartition_key
      # items[:activity_loans_charges] = { activity_value: 2536 , activity_ratio: 0.23} ALREADY COMPUTED AND PONDERATED WITH repartition_key
      # items[:activity_farmer_wages] = { activity_value: 1250 , activity_ratio: 0.23}  ALREADY COMPUTED AND PONDERATED WITH repartition_key
      ### REALISED
      ## Main & Others Direct Activity Products
      # items[:real_proportional_main_product_products] ex : 32561,25 (€)
      # items[:real_fixed_direct_products] ex : 1562,12 (€)
      ## Proportionnal & Fixed  Direct Activity Charges
      # items[:real_proportional_direct_charges] ex : 5825,12 (€)
      # items[:real_fixed_direct_charges] ex : 1526,52 (€)
      # items[:real_gross_margin] ex : 21523,23 (€)

      vcall = EconomicIndicator.activity_simulator(activity, @campaign)
      unit = Unit.find(vcall[:main_product_yield_unit_id])
      @work_unit = unit.symbol || unit.work_code || unit.reference_name
      @area_unit = Onoma::Unit.find(vcall[:area_unit]).symbol == '.' ? nil : Onoma::Unit.find(vcall[:area_unit]).symbol
      @total_area = vcall[:total_area]
      vcall
    end

    def compute_variety_result(vcall)
      call = vcall.clone
      # planned direct products and charges
      %i[proportional_main_product_products fixed_direct_products proportional_direct_charges fixed_direct_charges gross_margin].each do |key|
        default = call[key]
        call[key] = {
          default: default,
          per_area: per_area(default),
          per_unit: per_unit(call[:main_product_yield]),
        }
      end
      # real direct products and charges
      %i[real_proportional_main_product_products real_fixed_direct_products real_proportional_direct_charges real_fixed_direct_charges real_gross_margin].each do |key|
        default = call[key]
        call[key] = {
          default: default,
          per_area: per_area(default),
          per_unit: per_unit(call[:main_product_yield]),
        }
      end
      # planned indirect products and charges
      %i[activity_indirect_products activity_indirect_charges activity_employees_wages activity_depreciations_charges activity_loans_charges activity_farmer_wages activity_cash_provisions].each do |key|
        default = call[key][:activity_value]
        ratio = call[key][:activity_ratio]
        call[key] = {
          default: default,
          activity_key_ratio: ratio,
          per_area: per_area(default),
          per_unit: per_unit(call[:main_product_yield]),
        }
      end
      # real indirect products and charges
      %i[real_activity_indirect_products real_activity_indirect_charges real_activity_employees_wages real_activity_depreciations_charges real_activity_loans_charges real_activity_farmer_wages real_activity_cash_provisions].each do |key|
        default = call[key][:activity_value]
        ratio = call[key][:activity_ratio]
        call[key] = {
          default: default,
          activity_key_ratio: ratio,
          per_area: per_area(default),
          per_unit: per_unit(call[:main_product_yield]),
        }
      end
      call[:yield] = {
        default: call[:main_product_yield],
        unit: @area_unit.present? ? "#{@work_unit}/#{@area_unit}" : @work_unit
      }
      call[:work_unit] = "#{@currency}/#{@work_unit}"
      call[:area_unit] = @area_unit.present? ? "#{@currency}/#{@area_unit}" : @currency
      call[:total_area] = @total_area.in(@area_unit).round_l
      # compute net_margin
      net_margin = compute_net_margin(call)
      call[:net_margin] = {
        default: net_margin,
        per_area: per_area(net_margin),
        per_unit: per_unit(call[:main_product_yield]),
      }
      # compute production_cost
      production_cost = compute_production_cost(call)
      call[:production_cost] = {
        default: production_cost,
        per_area: per_area(production_cost),
        per_unit: per_unit(call[:main_product_yield]),
      }
      # compute real net_margin
      real_net_margin = compute_real_net_margin(call)
      call[:real_net_margin] = {
        default: real_net_margin,
        per_area: per_area(real_net_margin),
        per_unit: per_unit(call[:main_product_yield]),
      }
      # compute real production_cost
      real_production_cost = compute_real_production_cost(call)
      call[:real_production_cost] = {
        default: real_production_cost,
        per_area: per_area(real_production_cost),
        per_unit: per_unit(call[:main_product_yield]),
      }
      u_call = with_products(call)
      with_real_products(u_call)
    end

    def with_products(vcall)
      call = vcall.clone
      default = vcall[:proportional_main_product_products][:default]
      call[:product] = {
        default: default,
        per_area: per_area(default),
        per_unit: per_unit(vcall[:yield][:default]),
      }
      threshold_product = default - call[:net_margin][:default]
      call[:threshold_product] = {
        default: threshold_product ,
        per_area: per_area(threshold_product),
        per_unit: per_unit(vcall[:yield][:default]),
      }
      call
    end

    def with_real_products(vcall)
      call = vcall.clone
      default = vcall[:real_proportional_main_product_products][:default]
      call[:real_product] = {
        default: default,
        per_area: per_area(default),
        per_unit: per_unit(vcall[:yield][:default]),
      }
      threshold_product = default - call[:real_net_margin][:default]
      call[:real_threshold_product] = {
        default: threshold_product ,
        per_area: per_area(threshold_product),
        per_unit: per_unit(vcall[:yield][:default]),
      }
      call
    end

    def per_area(val)
      @per_area = '%.2f' % (val.to_f/@total_area)
      @area_unit.present? ? "#{@per_area} #{@currency}/#{@area_unit}" : "#{@per_area} #{@currency}"
    end

    def per_unit(default_yield)
      "#{'%.2f' % (@per_area.to_f/default_yield)} #{@currency}/#{@work_unit}"
    end

    def compute_net_margin(vcall)
      call = vcall.clone
      all_charges = 0.0
      %i[activity_indirect_charges activity_employees_wages activity_depreciations_charges activity_loans_charges activity_farmer_wages].each do |key|
        all_charges += call[key][:default]
      end
      ((call[:gross_margin][:default] + call[:activity_indirect_products][:default]) - all_charges).round(2)
    end

    def compute_production_cost(vcall)
      call = vcall.clone
      all_charges = 0.0
      %i[proportional_direct_charges fixed_direct_charges activity_indirect_charges activity_employees_wages activity_depreciations_charges activity_loans_charges activity_farmer_wages].each do |key|
        all_charges += call[key][:default]
      end
      all_charges.round(2)
    end

    def compute_real_net_margin(vcall)
      call = vcall.clone
      all_charges = 0.0
      %i[real_activity_indirect_charges real_activity_employees_wages real_activity_depreciations_charges real_activity_loans_charges real_activity_farmer_wages].each do |key|
        all_charges += call[key][:default]
      end
      ((call[:real_gross_margin][:default] + call[:real_activity_indirect_products][:default]) - all_charges).round(2)
    end

    def compute_real_production_cost(vcall)
      call = vcall.clone
      all_charges = 0.0
      %i[real_proportional_direct_charges real_fixed_direct_charges real_activity_indirect_charges real_activity_employees_wages real_activity_depreciations_charges real_activity_loans_charges real_activity_farmer_wages].each do |key|
        all_charges += call[key][:default]
      end
      all_charges.round(2)
    end

end
