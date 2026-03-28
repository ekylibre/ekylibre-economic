//= require economic_handler

(function (E, C, $, Ec) {
  $(document).behave("load", ".fixed-economics", function() {
    /* Create an Economic Handler when arriving on market-treshold page */
    Ec.handler = new Ec.EconomicHandler($('.cobble'));
    /* Display/Hide indirect charges for a specific cobble */
    $(".entry a").click(function(event) {
      $(this).children().toggleClass('icon-minus icon-plus')
      $.each($(this).closest('.full-table').find('.hidden-eco'), function() {
        $(this).slideToggle(1);
      });
      event.stopImmediatePropagation();
      return false;
   });
    /* Top-Slider event handler */
    document.getElementById("top-sliders").oninput = function(event) {
      that = event.target;
      if ($(that).hasClass('slider-salary')){
        Ec.handler.update_salary_charge($(that))
      } else {
        Ec.handler.update_non_salary_direct_charge($(that))
      }
    }
  });
  /* Yield-slider event handler*/
  $(document).on("slided", "*[data-regulator]", function() {
    var element = $(this);
    if (element.hasClass('slider-yield')){
      cobbler = Ec.handler.cobbler_find(element.closest('.cobble').attr('id'));
      cobbler.update_yield(parseInt(element.next().text()));
    }
  });
  $(document).behave("load", ".margin-economics", function() {
    /* Display/Hide indirect charges for a specific cobble */
    $(".entry a").click(function(event) {
      $(this).children().toggleClass('icon-minus icon-plus')
      $.each($(this).closest('.full-table').find('.hidden-eco'), function() {
        $(this).slideToggle(1);
      });
      event.stopImmediatePropagation();
      return false;
   });
  });

  // Economic margin and simulation
  E.onDomReady(function() {
    $('.format-economic-result.without-unit').each(function() {
      let value = this.innerText.split(' ')
      $(this).html(C.toBudgetCurrency(value[0]))
      if (value[1] !== undefined) {
        return this.insertAdjacentHTML('afterend', `<span class='h4 format-economic-result'> ${value[1]}</span>`);
      }
    })
  });

})(ekylibre, calcul, jQuery, window.Economic = window.Economic || {});