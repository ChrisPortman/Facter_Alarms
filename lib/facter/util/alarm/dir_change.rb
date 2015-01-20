module Facter::Util
  class Alarm::Dir_change < Facter::Util::Alarm
    def test
      begin
        directories = config['directories'].keys || []
      rescue
        directories = []
      end

      unless directories.is_a? Array
        raise Exception
      end
      
      dirs = {}

      directories.each do |dir|
        begin
          Dir.glob(File.join(dir, "**", "*")).select do |f|
            File.file?(f) and File.readable?(f)
          end .each do |f|
            age  = Time.now - File.stat(f).mtime
            dirs[dir] = age.to_i
          end
        rescue
        end
      end

      dirs
    end

    def state
      worst_state = 'OK'
      bad_dirs    = []

      result.each do |dir,age| 
        begin
          warning  = config[dir]['WARNING'].to_i
          critical = config[dir]['CRITICAL'].to_i
        rescue
          warning  = 10.to_i
          critical = 20.to_i
        end

        bad_dirs.push(dir) if age > warning

        unless worst_state == 'CRITICAL'
          case
          when age > critical
            worst_state = 'CRITICAL'
          when age > warning
            worst_state = 'WARNING'
          end
        end
      end

      @config['bad_dirs'] = bad_dirs
      worst_state
    end
    
    def message
      if %w(CRITICAL WARNING).include?(status)
        "The following directories are older than recommended: #{config['bad_dirs'].join(', ')}"
      end
    end
  end
end
