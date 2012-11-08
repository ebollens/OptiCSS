require 'rubygems'
require 'extensions/kernel'
require_relative 'Strategy'

module OptiCSS
  
  module Strategy
    
    class RedundancyRemoval < Strategy
      
      def execute properties
        
        @parser.each_media_query do |idx, media_query, definitions|
      
          current = definitions.length-1

          while current >= 0

            definition = definitions[current]

            definition[:selectors].each do |selector|
              for comp in 0..(current-1) 
                if definitions[comp][:selectors].include? selector
                  definition[:declarations].each do |key,value|
                    definitions[comp][:declarations].delete key if definitions[comp][:declarations][key]
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