module Facter::Util
  class Alarm::Mem_load < Facter::Util::Alarm
    def test
      mem_info = {}
      begin
        File.readlines('/proc/loadavg').each do |l|
          if match = /^(.+):\s+(\d+)/.match(l)
            mem_info[match[1]] = match[2]
          end
        end
      rescue
        return {}
      end

      metrics = {}
      metrics['mem_used'] = mem_info[]

      num_cpus = Facter.value(:processorcount) || 1
      cpu_load.split(/\s+/)[1].to_f / num_cpus.to_i
    end

    def state
      begin
        warning  = config['WARNING']  || 10
        critical = config['CRITICAL'] || 15
      rescue
        warning  = 10
        critical = 15
      end

      case
      when result > critical.to_f
        'CRITICAL'
      when result > warning.to_f
        'WARNING'
      else
        'OK'
      end
    end
    
    def message
      "CPU Load is at #{result} per CPU"
    end
  end
end
