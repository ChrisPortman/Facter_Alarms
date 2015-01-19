module Facter::Util
  class Alarm::Cpu_load < Facter::Util::Alarm
    def test
      begin
        cpu_load = File.read('/proc/loadavg')
      rescue
      end

      num_cpus = Facter.value(:processorcount) || 1
      cpu_load.split(/\s+/)[1].to_f
    end

    def state
      begin
        warning  = config['WARNING']
        critical = config['CRITICAL']
      rescue
        warning  = 10
        critical = 15
      end
      
      case
      when result > critical
        'CRITICAL'
      when result > warning
        'WARNING'
      else
        'OK'
      end
    end
  end
end
