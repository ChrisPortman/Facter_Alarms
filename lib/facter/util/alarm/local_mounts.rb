module Facter::Util
  class Alarm::Local_mounts < Facter::Util::Alarm
    def test
      mounts = File.read('/proc/mounts')
      
      mount_details = {}
      
      mounts.split("\n").each do |line|
        mount_attrs = line.split(/\s+/)
        mount_details[mount_attrs[1]] = {
          'device'  => mount_attrs[0],
          'fstype'  => mount_attrs[2],
          'options' => mount_attrs[3],
        }
      end
      
      mount_details.select do |k,v|
        v['fstype'] == 'ext4'
      end .keys
    end

    def state
      worst_state = 'OK'
      @error = []

      begin
        mounts  = config['mounts'] || ['/']
      rescue
        mounts  = ['/']
      end

      mounts.each do |m|
        unless result.include?(m)
          worst_state = 'CRITICAL'
          @error << m
        end
      end

      worst_state
    end
    
    def message
      if ! @error.empty?
        "Mounts not mounted: #{@error.join(', ')}"
      else
        "All Mounts are mounted"
      end
    end
  end
end
