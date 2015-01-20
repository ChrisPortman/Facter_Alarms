module Facter::Util
  class Alarm::Conntrack < Facter::Util::Alarm
    def test
      if conntrack_available?
        begin
          if conn_max == 0
            return 0
          end
        
          if conn_count == 0
            return 0
          end
        rescue
          return nil
        end
        
        (conn_count / conn_max * 100).to_f.round(2)
      else
        @error = 'Conntrack not available'
        nil
      end
    end

    def state
      if result.nil? or @error
        return 'UNKNOWN'
      end
      
      worst_state = 'OK'

      begin
        warning  = config['WARNING']  || 67
        critical = config['CRITICAL'] || 85
      rescue
        warning  = 67 
        critical = 85
      end

      unless worst_state == 'CRITICAL'
        case
        when result.to_f > critical.to_f
          worst_state = 'CRITICAL'
        when result.to_f > warning.to_f
          worst_state = 'WARNING'
        end
      end
 
      worst_state
    end
    
    def message
      if @error
        @error
      else
        "Conntrack is at #{result}%"
      end
    end
    
    private
    
    def conntrack_available?
      begin
        proc = File.read("/proc/modules")
      rescue
        return false
      end

      ! proc.scan(/conntrack/).empty?
    end
    
    def netfilter_base_dir
      %w(
        /proc/sys/net/ipv4/netfilter/
        /proc/sys/net/netfilter
      ) .each do |dir|
        if File.directory?(dir)
          return dir
        end
      end
      @error = 'Unable to determine the netfilter base dir'
      nil
    end
    
    def count_file
      %w(
        nf_conntrack_count
        ip_conntrack_count
      ). each do |file|
        if File.file?(File.join(netfilter_base_dir, file))
          return File.join(netfilter_base_dir, file)
        end
      end
      @error = 'Unable to determine the conntrack max file'
      nil
    end
    
    def max_file
      %w(
        nf_conntrack_max
        ip_conntrack_max
      ). each do |file|
        if File.file?(File.join(netfilter_base_dir, file))
          return File.join(netfilter_base_dir, file)
        end
      end
      @error = 'Unable to determine the conntrack max file'
      nil
    end
    
    def conn_count
      begin
        num = File.read(count_file).chomp
        unless num =~ /^\d+$/
          @error = 'Invalid number for conntrack count'
          raise Exception
        end
        num.to_f
      rescue
        nil
      end
    end

    def conn_max
      begin
        num = File.read(max_file).chomp
        unless num =~ /^\d+$/
          @error = 'Invalid number for conntrack max'
          raise Exception
        end
        num.to_f
      rescue
        nil
      end
    end
  end
end
