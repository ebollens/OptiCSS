require 'rubygems'
require 'extensions/kernel' if defined?(require_relative).nil?
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
                              
        @parser.each_media_query do |idx, media_query, definitions|
          
          new_definitions = []
          
          current = 0
          while current < definitions.length
                    
            # Skip if property is an aggregate property
            if (definitions[current][:declarations].keys & aggregate_properties).length > 0
              new_definitions.push(definitions[current])
              current += 1
              next
            end
            
            adjacency_matrix = {}
            definitions[current][:selectors].each do |selector|
              adjacency_matrix[selector] = {}
              definitions[current][:declarations].keys.each do |declaration|
                adjacency_matrix[selector][declaration] = true
              end
            end
            
            ahead = current + 1
            while ahead < definitions.length
              intersected_selectors = definitions[current][:selectors] & definitions[ahead][:selectors]
              if intersected_selectors.length > 0
                intersected_declarations = definitions[current][:declarations].keys & definitions[ahead][:declarations].keys
                intersected_declarations.clone.each do |declaration|
                  is_vendor_prefix = false
                  definitions[current][:declarations][declaration].each do |v|
                    is_vendor_prefix = true if v.match /\s\-/
                  end
                  intersected_declarations.delete declaration if is_vendor_prefix
                end
                if intersected_declarations.length > 0
                  intersected_selectors.each do |selector|
                    intersected_declarations.each do |declaration|
                      adjacency_matrix[selector][declaration] = false
                    end
                  end
                end
              end
              
              ahead += 1
              
            end
            
            declarations_counter = {}
            definitions[current][:declarations].keys.each do |declaration|
              declarations_counter[declaration] = 0
            end
            adjacency_matrix.each do |selector,declarations|
              declarations.each do |declaration, adjacent|
                declarations_counter[declaration] += 1 if adjacent
              end
            end
            
            declaration, count = declarations_counter.max_by { |x,y| y }
            while count and count > 0
              new_selectors = []
              new_declarations = {}
              adjacency_matrix.each do |selector,declarations|
                new_selectors.push selector if declarations[declaration]
              end
              definitions[current][:declarations].keys.each do |declaration|
                match = true
                new_selectors.each do |selector|
                  match = false unless adjacency_matrix[selector][declaration]
                end
                next unless match
                new_declarations[declaration] = definitions[current][:declarations][declaration]
                declarations_counter[declaration] -= count
              end
              new_definitions.push({
                :selectors => new_selectors,
                :declarations => new_declarations
              })
              declaration, count = declarations_counter.max_by { |x,y| y }
            end
            
            current += 1
            
          end
          
          @parser.sheet[idx][:definitions] = new_definitions
          
        end
                              
        super properties
        
      end
      
    end
    
  end
  
end