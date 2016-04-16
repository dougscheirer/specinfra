require 'json'
module Specinfra
  module Backend
    class Saltstack < Exec
      def initialize(config = {})
        super
        begin
        rescue LoadError
        end
      end

      def saltscape(s) 
	s.gsub('$','\$')
      end

      def run_command(cmd, opts={})
        cmd = build_command(cmd)
        cmd = add_pre_command(cmd)
        cmd = saltscape(cmd)
        # puts "cmd: #{cmd}"

	# puts "run this: sudo salt '#{config[:minion]}' cmd.run --out json \"#{cmd}\" | jq -r '.[]'"
        out = `sudo salt '#{config[:minion]}' cmd.run --out json "#{cmd}" 2>/dev/null`
        exitcode = $?.exitstatus

        out = JSON.parse(out)[config[:minion]]
	if /Minion did not return/.match(out) 
          exitcode = 1
        end
        
        if @example
          @example.metadata[:command] = cmd
          @example.metadata[:stdout]  = out
        end

        # puts "ret: #{ret} out: #{out}"
        CommandResult.new :stdout => out, :exit_status => exitcode
      end

      def build_command(cmd)
        cmd
      end

      def add_pre_command(cmd)
        cmd
      end

      def send_file(from, to)
        FileUtils.cp(from, File.join(ct.config_item('salt.rootfs'), to))
      end

      def config
        get_config(:salt)
      end
    end
  end
end
