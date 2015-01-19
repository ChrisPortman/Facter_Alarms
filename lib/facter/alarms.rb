require 'facter'
require 'yaml'
require 'facter/util/alarm'

Facter.add(:alarms) do
  confine :kernel => :linux

  #load the alarms config
  config = {}
  if File.readable?('/etc/alarming/alarms.conf')
    begin
      config = YAML.load( File.read('/etc/alarming/alarms.conf') )
    rescue
    end
  end

  #Get all the available alarm classes
  alarm_classes = Facter::Util::Alarm.alarms
  
  #Get an instance of each class.
  alarm_instances = []
  alarm_classes.each do |a|
    alarm_instances.push( Facter::Util::Alarm.const_get(a).new(config) )
  end

  alarms = {}

  alarm_instances.each do |obj|
    begin
      name_method  = obj.method(:name)
      test_method  = obj.method(:test)
      state_method = obj.method(:state)
      
      alarms[name_method.call] = {
        'value' => test_method.call,
        'state' => state_method.call,
      }
    rescue
    end
  end

  setcode do
    alarms
  end
end
    




