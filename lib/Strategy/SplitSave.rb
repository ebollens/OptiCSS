require 'rubygems'
require 'extensions/kernel' if defined?(require_relative).nil?
require_relative 'Strategy'

module OptiCSS
  
  module Strategy
    
    class SplitSave < Strategy
      
      def execute properties
        
        basename = properties[:filename].gsub /\.css$/, ""
        
        file_counter = 1
        selector_counter = 0
        handle = File.open("#{basename}-#{file_counter}.css", 'w')
        
        @parser.each_media_query do |idx, media_query, definitions| 

          handle.write "@media #{media_query}{" unless media_query == :none

          definitions.each do |definition|
            
            selector_counter += definition[:selectors].length
            
            if selector_counter > 4095
              selector_counter = definition[:selectors].length
              handle.write "}" unless media_query == :none
              handle.close
              file_counter += 1
              handle = File.open("#{basename}-#{file_counter}.css", 'w')
              handle.write "@media #{media_query}{" unless media_query == :none
            end

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
        
        handle.close
        
        File.open(properties[:filename], 'w') do |handle|
          (1..file_counter).each do |i|
            handle.write "@import \"#{File.basename(basename)}-#{i}.css\"; "
          end
        end
        
        super properties
        
      end
      
    end
    
  end
  
end