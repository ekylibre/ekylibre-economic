(function (Ec, $) {
  class EconomicCobble {

    constructor(cobble) {
      var data_ratio;
      this.cobble = cobble;
      this.id = this.cobble.attr('id');
      this.defaults = {};
      this.ratios = {};
      $.each(['yield', 'threshold_product', 'total-area', 'fixed_direct_products', 'proportional_direct_charges', 'gross_margin', 'fixed_direct_charges', 'activity_indirect_products', 'activity_indirect_charges', 'activity_employees_wages', 'activity_depreciations_charges', 'activity_loans_charges', 'activity_farmer_wages', 'activity_cash_provisions'], (index, key) => {
        this[key+"_work"] = this.cobble.find('.'+key+"-work")
        this[key+"_area"] = this.cobble.find('.'+key+"-area")
        this.defaults[key] = parseFloat(this.cobble.find('.'+key+"-default").data('default'));
        if (data_ratio = this.cobble.find('.'+key+"-default").data('ratio')){
          this.ratios[key] = parseFloat(data_ratio);
        }
      });
      this.defaults['work-unit'] = this.cobble.find('.yield-default').data('work-unit');
      this.defaults['area-unit'] = this.cobble.find('.yield-default').data('area-unit');
      this.yield_value = this.cobble.find('.slider-yield-vary');
    };

    /**
     * Updates default value for slided indirect_charge
     */
     update_indirect_charge(diff, type) {
      this.defaults[type] += Math.round(diff * this.ratios[type]);
      this.cobble.find(`.${type}-default`).data('default', this.defaults[type])
      this.recalculate_indirect_charge(type)
      this.recalculate_product()
    }

    /**
     * Calculations & setter for modified indirect_charges
     */
    recalculate_indirect_charge(type) {
      /* TODO: display new i_charges values */
      var ic_value_area = (this.defaults[type]/this.defaults['total-area']).toFixed(2)
      var ic_value_work = (ic_value_area / parseInt(this.yield_value.text())).toFixed(2)
      this[`${type}_area`].text(`${calcul.toBudgetCurrency(ic_value_area)} ${this.defaults['area-unit']}`)
      this[`${type}_work`].text(`${ic_value_work} ${this.defaults['work-unit']}`)
    }

    /**
     * Calculation & setter for the threshold product
     * SUM(activity_ratio * activity_value) = gross_margin
     * gross_margin = SUM(direct_products) - SUM(direct_charges)
     * product = yield * price per work_unit * area
     */
     recalculate_product(type) {
      var def = this.defaults;
      var product = 0;
      /* Adding every indirect charges */
      $.each(['activity_indirect_charges', 'activity_employees_wages', 'activity_depreciations_charges', 'activity_loans_charges', 'activity_farmer_wages', 'activity_cash_provisions'], (i, key) => {
        product += def[key];
      })
      /* Removing indirect_products */
      product -= def['activity_indirect_products']
      /* Set new value of gross_margin */
      var gross_margin_area = (product/def['total-area']).toFixed(2)
      var gross_margin_work = (gross_margin_area/this.defaults['yield']).toFixed(2)
      this.gross_margin_area.text(`${calcul.toBudgetCurrency(gross_margin_area)} ${this.defaults['area-unit']}`)
      this.gross_margin_work.text(`${calcul.toBudgetCurrency(gross_margin_work)} ${this.defaults['work-unit']}`)
      /* Adding direct charges */
      product += def['proportional_direct_charges'] + def['fixed_direct_charges']
      /* Removing fixed direct product */
      product -= def['fixed_direct_products']
      var product_area = (product/def['total-area']).toFixed(2)
      var product_work = (product_area/this.defaults['yield']).toFixed(2)
      this.defaults['threshold_product'] = product
      this.threshold_product_area.text(`${calcul.toBudgetCurrency(product_area)} ${this.defaults['area-unit']}`)
      this.threshold_product_work.text(`${calcul.toBudgetCurrency(product_work)} ${this.defaults['work-unit']}`)
      this.update_chart_threshold(product_work)
    }

    /**
     * Update treshold on cobble highchart chart
     */
    update_chart_threshold(threshold) {
      if (!this.serie){
        var chart = Highcharts.charts.find(chart => $(chart.container).closest('.cobble')[0] == this.cobble[0]);
        this.serie = chart.series.find(serie => serie.name == I18n.t("front-end.labels.market_threshold"))
      }
      if (this.serie){
        var size = this.serie.data.length;
        this.serie.update({data: Array(size).fill(parseFloat(threshold))});
      }
    }

    /**
     * Updates all yield related values
     */
    update_yield(new_yield) {
      var that = this;
      this.defaults['yield'] = new_yield;
      $.each(['threshold_product', 'fixed_direct_products', 'proportional_direct_charges', 'gross_margin', 'fixed_direct_charges', 'activity_indirect_products', 'activity_indirect_charges', 'activity_employees_wages', 'activity_depreciations_charges', 'activity_loans_charges', 'activity_farmer_wages', 'activity_cash_provisions'], function(i, key) {
        that[key+'_work'].text(that.work_calculations(key, new_yield))
      });
    }

    /**
     * Redo calculations for a type_work param on yield change
     * @param {String} type - type ofty work param to update
     * @param {Integer} new_yield - yield given via slider
     */
    work_calculations(type, new_yield) {
      if (this.defaults["total-area"] == 0 || new_yield == 0){
        return "0.00 "+this.defaults['work-unit']
      } else {
        var value = (this.defaults[type] / (this.defaults["total-area"] * new_yield)).toFixed(2)
        if (type == "threshold_product"){
          this.update_chart_threshold(value)
        }
        return [value, this.defaults['work-unit']].join(' ')
      }
    }


  }
  Ec.EconomicCobble = EconomicCobble;
})(window.Economic = window.Economic || {}, jQuery);
