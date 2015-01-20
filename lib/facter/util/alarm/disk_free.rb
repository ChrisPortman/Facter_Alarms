module Facter::Util
  class Alarm::Disk_free < Facter::Util::Alarm
    def test
      mounts = File.read('/proc/mounts')
      df     = %x{df}
      
      mount_details = {}
      
      mounts.split("\n").each do |line|
        mount_attrs = line.split(/\s+/)
        mount_details[mount_attrs[1]] = {
          'device'  => mount_attrs[0],
          'fstype'  => mount_attrs[2],
          'options' => mount_attrs[3],
        }
      end
      
      df.split("\n").slice(1..-1).each do |line|
        df_attrs = line.split(/\s+/)
        mount_details[df_attrs[5]]['blocks'] = df_attrs[1]
        mount_details[df_attrs[5]]['used'] = df_attrs[2]
        mount_details[df_attrs[5]]['available'] = df_attrs[3]
        mount_details[df_attrs[5]]['use'] = df_attrs[4]
      end

      final = {}
      mount_details.select do |k,v|
        v['fstype'] == 'ext4' and v['use']
      end .each do |k,v|
        final[k] = {
          'use' => v['use']
        }
      end
      
      final
    end

    def state
      worst_state = 'OK'
      result.each do |k,v| 
        begin
          warning  = config[k]['WARNING'].to_i
          critical = config[k]['CRITICAL'].to_i
        rescue
          warning  = 90.to_i 
          critical = 95.to_i
        end

        unless worst_state == 'CRITICAL'
          case
          when v['use'].to_i > critical
            worst_state = 'CRITICAL'
          when v['use'].to_i > warning
            worst_state = 'WARNING'
          end
        end
      end

      worst_state
    end
    
    def message
      message = []
      result.each do |k,v|
        message << "#{k}: #{v['use']}"
      end
      message.join(', ')
    end
  end
end
