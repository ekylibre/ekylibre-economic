module EkylibreEconomic
  class Engine < ::Rails::Engine

    initializer :ekylibre_economic_i18n do |app|
      app.config.i18n.load_path += Dir[EkylibreEconomic::Engine.root.join('config', 'locales', '**', '*.yml')]
    end

    initializer :ekylibre_economic_extend_navigation do |_app|
      EkylibreEconomic::ExtNavigation.add_navigation_xml_to_existing_tree
    end

    initializer :ekylibre_economic_beehive do |app|
      app.config.x.beehive.cell_controller_types << :cash_forecast
      app.config.x.beehive.cell_controller_types << :economic_charges_by_activity
    end

    initializer :ekylibre_economic_restfully_manageable do |app|
      app.config.x.restfully_manageable.view_paths << EkylibreEconomic::Engine.root.join('app', 'views')
    end

    initializer :ekylibre_economic_import_javascripts do
      tmp_file = Rails.root.join('tmp', 'plugins', 'javascript-addons', 'plugins.js.coffee')
      tmp_file.open('a') do |f|
        import = '#= require economic'
        f.puts(import) unless tmp_file.open('r').read.include?(import)
      end
    end

    initializer :ekylibre_economic_import_stylesheets do
      tmp_file = Rails.root.join('tmp', 'plugins', 'theme-addons', 'themes', 'tekyla', 'plugins.scss')
      tmp_file.open('a') do |f|
        import = '@import "economic/tekyla/main.scss";'
        f.puts(import) unless tmp_file.open('r').read.include?(import)
      end
    end

  end
end
