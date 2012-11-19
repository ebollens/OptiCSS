require 'rubygems'
require 'extensions/kernel'
require_relative 'Strategy'

module OptiCSS
  
  module Strategy
    
    class Save < Strategy
      
      def execute properties
    
        File.open(properties[:filename], 'w') do |handle|

          @parser.each_media_query do |idx, media_query, definitions| 

            handle.write "@media #{media_query}{" unless media_query == :none

            definitions.each do |definition|

              selector_string = definition[:selectors].join(',')

              declarations_arr = []
              definition[:declarations].each do |key, values|
                values.each do |value|
                  declarations_arr.push "#{key}:#{value.strip}"
                end
              end

              handle.write "#{selector_string}{#{declarations_arr.join(';')}}"

            end

            handle.write "}" unless media_query == :none

          end

        end
        
        super properties
        
      end
      
    end
    
  end
  
end