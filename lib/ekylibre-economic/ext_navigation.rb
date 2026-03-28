module EkylibreEconomic
  class ExtNavigation
    def self.add_navigation_xml_to_existing_tree
      ext_navigation = ExtNavigation.new
      ext_navigation.build_new_tree
    end

    attr_reader :economic_navigation_tree, :new_navigation_tree,
                :economic_xml_navigation_childrens

    def initialize
      @economic_navigation_tree = Ekylibre::Navigation::Tree
                                    .load_file(economic_navigation_file_path,
                                               :navigation,
                                               %i[part group item])
      @economic_xml_navigation_childrens = init_economic_navigation_childrens

    end

    def build_new_tree
      @economic_navigation_tree.children.each do |child|
        after_part = after_part_value(child)

        Ekylibre::Navigation.tree.insert_part_after(child, after_part)
      end

      @new_navigation_tree = Ekylibre::Navigation.tree
      @new_navigation_tree
    end

    private

    def init_economic_navigation_childrens
      parts = navigation_to_xml.xpath('//part')

      parts.map do |part|
        { after_part: part.attribute('after-part').value, node: part }
      end
    end

    def after_part_value(economic_navigation_child)
      selected_child = @economic_xml_navigation_childrens.select do |economic_xml_navigation_child|
                         economic_xml_navigation_child[:node].attribute('name').value == economic_navigation_child.name.to_s
                       end

      selected_child.first[:after_part]
    end

    def navigation_to_xml
      navigation_xml_file = File.open(economic_navigation_file_path)

      xml = Nokogiri::XML(navigation_xml_file) do |config|
        config.strict.nonet.noblanks
      end

      navigation_xml_file.close

      xml
    end

    def economic_navigation_file_path
      EkylibreEconomic.root.join('config', 'navigation.xml')
    end
  end
end
