//=require economic_cobble

(function (Ec, $) {
  class EconomicHandler {

    constructor(selector) {
      this.cobbles = selector.map((x,y) => new Ec.EconomicCobble($(y)))
    };

    /**
     * Find one if its cobble by id
     * @param {String} id - cobble id
     */
    cobbler_find(id) {
      return this.cobbles.toArray().find(x => x.id === id)
    }

    /**
     * Update top slider span text with slided value
     * @param {Element} element - slider element
     */
    update_slider_value(element){
      var span = element.next();
      span.text(`${calcul.toBudgetCurrency(element.get(0).value)} ${span.data().unit}`);
    }

    /**
     * Update charge for a salary-slider (add percentage to span text)
     * @param {Element} element - slider element
     */
    update_salary_charge(element){
      var span = element.next();
      var new_value = element.get(0).value;
      var prev_value = element.prev().data('previous');
      var default_value = element.prev().data('default');
      var percentage = Math.round(((new_value - default_value)/default_value) * 100)
      var decorated_pc = percentage >= 0 ? `(+${percentage}%)` : `(${percentage}%)`
      if (!isFinite(percentage)){
        decorated_pc = ''
      }
      span.text(`${decorated_pc} ${calcul.toBudgetCurrency(new_value)} ${span.data('unit')}`);
      $.each(this.cobbles, (index, cobble) => {
        cobble.update_indirect_charge(new_value - prev_value, element.data('attr'))
      });
      element.prev().data('previous', element.get(0).value);
    }

    /**
     * Update charge for a non salary-slider top slider
     * @param {Element} element - slider element
     */
    update_non_salary_direct_charge(element){
      this.update_slider_value(element);
      var new_value = element.get(0).value;
      var prev_value = element.prev().data('previous');
      $.each(this.cobbles, (index, cobble) => {
        cobble.update_indirect_charge(new_value - prev_value, element.data('attr'))
      });
      element.prev().data('previous', element.get(0).value);
    }


  }
  Ec.EconomicHandler = EconomicHandler;
})(window.Economic = window.Economic || {}, jQuery);