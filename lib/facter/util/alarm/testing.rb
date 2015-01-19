module Facter::Util
  class Alarm::Testing < Facter::Util::Alarm
    def test
      rand(10)
    end

    def state
      case test
      when 0..5
        'CRITICAL'
      when 6..8
        'WARNING'
      when 9..10
        'OK'
      end
    end
  end
end
