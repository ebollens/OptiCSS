require 'rubygems'
require 'extensions/kernel' if defined?(require_relative).nil?
require 'pathname'
require_relative 'Parser'

module OptiCSS
  
  class Optimizer
    
    def initialize filename, &block
      
      @parser = OptiCSS::Parser.new filename
      
      @strategies = []
      
      instance_eval &block
      
    end
    
    def strategy strategy_name, properties = {}
      
      strategy = create_strategy strategy_name
      
      strategy and execute_strategy strategy, properties
      
    end
    
    def create_strategy strategy_name
      
      return false unless File.exists? "#{File.dirname(Pathname.new(__FILE__).realpath)}/Strategy/#{strategy_name}.rb"
      
      require_relative "Strategy/#{strategy_name}.rb"
      
      strategy_class_name = eval "OptiCSS::Strategy::#{strategy_name.to_s}"
      
      strategy_class_name.new @parser
      
    end
    
    def execute_strategy strategy, properties
      
      return false unless strategy.respond_to? :execute
      
      @parser = strategy.execute properties
      
      true
      
    end
    
    def split_save filename
      
      strategy "SplitSave", :filename => filename
      
    end
    
    def save file
      
      strategy "Save", :filename => file
      
    end
    
  end
  
end
