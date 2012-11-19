require 'rubygems'
require_relative '../package/css_parser/lib/css_parser.rb'
include CssParser

module OptiCSS
  
  class Parser < CssParser::Parser
    
    attr_accessor :sheet
    
    def initialize filename, options = {}
      
      super options
      
      load_file!(filename)
      
      init_sheet!
      
    end
    
    def init_sheet!
      
      @sheet = []
      
      current_idx = -1
      current_media_query = false
      
      self.instance_variable_get(:@rules).each do |rule|

        rule[:media_types].push :all unless rule[:media_types].include? :all

        media_query = :none

        if rule[:media_types].length > 1 
          rule[:media_types].each do |media_type|
            media_query = media_type unless media_type == :all 
          end
        end

        unless media_query == current_media_query
          current_idx += 1
          current_media_query = media_query
          @sheet[current_idx] = Hash.new
          @sheet[current_idx][:media_query] = media_query
          @sheet[current_idx][:definitions] = []
        end

        definition = Hash.new
        definition[:selectors] = []
        rule[:rules].instance_variable_get(:@selectors).each do |selector|
          definition[:selectors].push selector.strip
        end

        definition[:declarations] = Hash.new
        rule[:rules].instance_variable_get(:@declarations).each do |declaration|
          definition[:declarations][declaration[0]] = [declaration[1][:value]]
          while declaration[1][:previous]
            declaration[1] = declaration[1][:previous]
            definition[:declarations][declaration[0]].unshift declaration[1][:value]
          end
        end

        @sheet[current_idx][:definitions].push definition

      end
      
    end
  
    def media_queries
      
      @sheet.keys
      
    end

    def each_media_query
      
      @sheet.each_index do |idx| 
        yield idx, @sheet[idx][:media_query], @sheet[idx][:definitions]
      end
      
    end
    
  end
  
end
