module Librevox
  # All commands should call `command` with the following parameters:
  #
  #   `name` - name of the command
  #   `args` - arguments as a string (optional)
  #
  # Commands *must* pass on any eventual block passed to them.
  module Commands
    # Executes a generic API command, optionally taking arguments as string.
    # @example
    #   socket.command "fsctl", "hupall normal_clearing"
    # @see http://wiki.freeswitch.org/wiki/Mod_commands
    def command name, args=""
      msg = "api #{name}"
      msg << " #{args}" if args && !args.empty?
      msg
    end

    def status
      command "status"
    end

    # Access the hash table that comes with FreeSWITCH.
    # @example
    #   socket.hash :insert, :realm, :key, "value"
    #   socket.hash :select, :realm, :key
    #   socket.hash :delete, :realm, :key
    def hash *args
      command "hash", args.join("/")
    end

    # Originate a new call.
    # @example Minimum options
    #   socket.originate 'sofia/user/coltrane', :extension => "1234"
    # @example With :dialplan and :context
    # @see http://wiki.freeswitch.org/wiki/Mod_commands#originate
    def originate url, args={}
      extension = args.delete(:extension)
      dialplan  = args.delete(:dialplan)
      context   = args.delete(:context)

      vars = args.map {|k,v| "#{k}=#{v}"}.join(",")

      arg_string = "{#{vars}}" + 
        [url, extension, dialplan, context].compact.join(" ")
      command "originate", arg_string
    end

    # FreeSWITCH control messages.
    # @example
    #   socket.fsctl :hupall, :normal_clearing
    # @see http://wiki.freeswitch.org/wiki/Mod_commands#fsctl
    def fsctl *args
      command "fsctl", args.join(" ")
    end

    def hupall cause=nil
      command "hupall", cause
    end

    # Park call.
    # @example
    #   socket.uuid_park "592567a2-1be4-11df-a036-19bfdab2092f"
    # @see http://wiki.freeswitch.org/wiki/Mod_commands#uuid_park
    def uuid_park uuid
      command "uuid_park", uuid
    end

    # Bridge two call legs together. At least one leg must be anwered.
    # @example
    #   socket.uuid_bridge "592567a2-1be4-11df-a036-19bfdab2092f", "58b39c3a-1be4-11df-a035-19bfdab2092f"
    # @see http://wiki.freeswitch.org/wiki/Mod_commands#uuid_bridge
    def uuid_bridge uuid1, uuid2
      command "uuid_bridge", "#{uuid1} #{uuid2}"
    end
    
    # Get list of queues in the callcenter
    # @example
    #   socket.callcenter_queue_list
    # @see http://wiki.freeswitch.org/wiki/Mod_callcenter
    def callcenter_queue_list
      response = command "callcenter_config", "queue list"
      response.content_from_db
    end
    
    # Get list of agents in the callcenter
    # @example
    #   socket.callcenter_agent_list
    # @see http://wiki.freeswitch.org/wiki/Mod_callcenter
    def callcenter_agent_list
      response = command "callcenter_config", "agent list"
      response.content_from_db
    end
    
    def callcenter_tier_list queue
      response = command "callcenter_config", "tier list '#{queue}'"
      response.content_from_db
    end
  end
end
