module Facter::Util
  class Alarm
    attr_reader :config, :result, :status

    def initialize(config = nil)
      @config = config[name] || {}
      @result = nil
      @state  = nil
    end
    
    def self.alarms
      Alarm.constants.select do |c|
        Alarm.const_get(c).is_a? Class
      end
    end
    
    def name
      n = self.class.name
      n.sub(/^.*::/, '').downcase
    end

    def get_result
      if result.nil?
        @result = test
      else
        result
      end
    end
    
    def get_status
      if @status.nil?
        @status = state
      else
        state
      end
    end
    
    def get_message
      message
    end
    
    def test
      'Not Implemented'
    end
    
    def state
      'OK'
    end
    
    def message
      nil
    end
  end
end

Dir.glob( File.join( File.dirname( File.absolute_path(__FILE__) ), 'alarm/*.rb' ) ) do |f|
  require f
end
