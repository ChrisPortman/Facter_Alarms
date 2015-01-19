module Facter::Util
  class Alarm
    attr_reader :config

    def initialize(config = nil)
      @config = config
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

    def test
      'Not Implemented'
    end
    
    def state
      'OK'
    end
  end
end

Dir.glob( File.join( File.dirname( File.absolute_path(__FILE__) ), 'alarm/*.rb' ) ) do |f|
  require f
end
