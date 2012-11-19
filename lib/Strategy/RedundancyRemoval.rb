require 'rubygems'
require 'extensions/kernel'
require_relative 'Strategy'

module OptiCSS
  
  module Strategy
    
    class RedundancyRemoval < Strategy
      
      def execute properties
        
        # Several properties are aggregates that accept multiple values.
        # Duplicates of these should not be removed as redundant, because
        # they may pertain to different portions of the aggregate.
        aggregate_properties = ['background', 'border', 'border-top',
                                'border-right', 'border-bottom', 'border-left',
                                'font', 'list-style', 'outline']
        
        # Loop though each media query to find redundant rules within the query
        @parser.each_media_query do |idx, media_query, definitions|
      
          current = definitions.length-1

          # From the last definition to the first definition
          while current >= 0

            definition = definitions[current]

            # For each selector in the definition
            definition[:selectors].each do |selector|
              
              # Try to match it to other definitions earlier in the sheet
              for comp in 0..(current-1) 
                
                if definitions[comp][:selectors].include? selector
                  
                  # For each declaration (property) in the definition
                  definition[:declarations].each do |key,values|
                    
                    # Skip if the property is not declared in the comparison
                    next unless definitions[comp][:declarations][key]
                    
                    # Skip if property is an aggregate property
                    next if aggregate_properties.include? key
                    
                    has_value = false
                    values.each do |v|
                      has_value = true unless v.match /\s\-/
                    end
                    
                    # Skip if all values contained are vendor-prefixed
                    next unless has_value
                    
                    delete_values = []
                    definitions[comp][:declarations][key].each_index do |idx|
                      delete_values.push idx unless definitions[comp][:declarations][key][idx].match /\s\-/
                    end
                    
                    # Sort indices from latter to former to make deleting safe
                    delete_values.sort! {|x,y| y <=> x }
                    
                    # Delete all the indices that were flagged as redundant
                    delete_values.each do |idx|
                      definitions[comp][:declarations][key].delete_at idx
                    end
                    
                    if definitions[comp][:declarations][key].length == 0
                      definitions[comp][:declarations].delete key
                    end
                    
                  end
                  
                end
                
              end
              
            end

            new_definitions = []
            
            definitions.each do |definition|
              
              new_definitions.push definition unless definition[:declarations].length == 0
              
            end

            @parser.sheet[idx][:definitions] = new_definitions

            current -= 1

          end

        end
        
        super properties
        
      end
      
    end
    
  end
  
end