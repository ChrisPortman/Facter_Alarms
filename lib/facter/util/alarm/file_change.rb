module Facter::Util
  class Alarm::File_change < Facter::Util::Alarm
    def test
      begin
        files = config['files'].keys || []
      rescue
        files = []
      end

      unless files.is_a? Array
        raise Exception
      end
      
      file_ages = {}

      files.select do |f|
        File.readable?(f)
      end .each do |f|
        age = Time.now - File.stat(f).mtime
        file_ages[f] = age.to_i
      end

      file_ages
    end

    def state
      worst_state = 'OK'
      bad_files   = []

      result.each do |file,age| 
        begin
          warning  = config[file]['WARNING'].to_i
          critical = config[file]['CRITICAL'].to_i
        rescue
          warning  = 2100.to_i # 35 Mins 
          critical = 3000.to_i # 50 Mins
        end

        bad_files.push(file) if age > warning

        unless worst_state == 'CRITICAL'
          case
          when age > critical
            worst_state = 'CRITICAL'
          when age > warning
            worst_state = 'WARNING'
          end
        end
      end

      @config['bad_files'] = bad_files
      worst_state
    end
    
    def message
      if %w(CRITICAL WARNING).include?(status)
        "The following files are older than recommended: #{config['bad_files'].join(', ')}"
      end
    end
  end
end
