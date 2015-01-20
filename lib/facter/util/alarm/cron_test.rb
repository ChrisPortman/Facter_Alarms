module Facter::Util
  class Alarm::Cron_test < Facter::Util::Alarm
    def test
      testfile = '/var/tmp/crontest'
      if File.readable?(testfile) 
        (Time.now - File.stat(testfile).mtime).to_i
      else
        nil
      end
    end

    def state
      begin
        warning  = config['WARNING']  || 120
        critical = config['CRITICAL'] || 300
      rescue
        warning  = 120
        critical = 300
      end

      if result.nil?
        return 'CRITICAL'
      end

      case
      when result > critical.to_i
        'CRITICAL'
      when result > warning.to_i
        'WARNING'
      else
        'OK'
      end
    end
    
    def message
      if %w(CRITICAL WARNING).include?(status)
        if result.nil?
          "Cron test file not readable"
        else
          "Crontab has not run in #{result.to_i} seconds"
        end
      else
        "Crontab is running"
      end
    end
  end
end
