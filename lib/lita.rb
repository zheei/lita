require "forwardable"
require "logger"
require "rbconfig"
require "set"
require "shellwords"

require "faraday"
require "multi_json"
require "puma"
require "rack"
require "redis-namespace"

# The main namespace for Lita. Provides a global registry of adapters and
# handlers, as well as global configuration, logger, and Redis store.
module Lita
  # The base Redis namespace for all Lita data.
  REDIS_NAMESPACE = "lita"

  class AddRobotError < StandardError; end

  class << self
    # The global registry of adapters.
    # @return [Hash] A map of adapter keys to adapter classes.
    def adapters
      @adapters ||= {}
    end

    # Creates a new [Lita::Robot] and adds it to the collection of robots that will be started
    # when [.run] is called.
    # @yieldparam [Lita::Configuration] config The new robot's configuration object.
    # @return [void]
    def add_robot
      raise AddRobotError unless block_given?

      new_config = Config.default_config
      yield config
      robots << Robot.new(new_config)
    end

    # Adds an adapter to the global registry under the provided key.
    # @param key [String, Symbol] The key that identifies the adapter.
    # @param adapter [Lita::Adapter] The adapter class.
    # @return [void]
    def register_adapter(key, adapter)
      adapters[key.to_sym] = adapter
    end

    # The global registry of handlers.
    # @return [Set] The set of handlers.
    def handlers
      @handlers ||= Set.new
    end

    # Adds a handler to the global registry.
    # @param handler [Lita::Handler] The handler class.
    # @return [void]
    def register_handler(handler)
      handlers << handler
    end

    # The global configuration object. Provides user settings for the robot.
    # @deprecated Use {Lita::Robot.config} instead.
    # @return [Lita::Config] The Lita configuration object.
    def config
      Lita.logger.warn(
        "lita.core.deprecated",
        old_method: "Lita.config",
        new_method: "Lita::Robot#config"
      )

      @config ||= Config.default_config
    end

    # Yields the global configuration object. Called by the user in a lita_config.rb file.
    # @deprecated Use {.add_robot} instead.
    # @yieldparam [Lita::Configuration] config The global configuration object.
    # @return [void]
    def configure
      Lita.logger.warn(
        "lita.core.deprecated",
        old_method: "Lita.configure",
        new_method: "Lita.add_robot"
      )
      yield config
    end

    # Clears the default configuration object. The next call to {Lita.config} will return a fresh
    # config object for the default robot.
    # @deprecated The default configuration should be avoided. Use {Lita::Robot}-specific
    # configuration.
    # @return [void]
    def clear_config
      Lita.logger.warn("lita.core.deprecated_no_replacement", old_method: "Lita.clear_config")
      @config = nil
    end

    # The global Logger object.
    # @return [::Logger] The global Logger object.
    def logger
      @logger ||= Logger.get_logger(config.robot.log_level)
    end

    # The root Redis object.
    # @return [Redis::Namespace] The root Redis object.
    def redis
      @redis ||= begin
        redis = Redis.new(config.redis)
        Redis::Namespace.new(REDIS_NAMESPACE, redis: redis)
      end
    end

    # Loads user configuration and starts the robot.
    # @param config_path [String] The path to the user configuration file.
    # @return [void]
    def run(config_path = nil)
      Config.load_user_config(config_path)

      if robots.empty?
        Robot.new(config).run
      else
        robots.each { |robot| robot.run }
      end
    end

    private

    def robots
      @robots ||= []
    end
  end
end

require_relative "lita/version"
require_relative "lita/common"
require_relative "lita/config"
require_relative "lita/util"
require_relative "lita/logger"
require_relative "lita/user"
require_relative "lita/source"
require_relative "lita/authorization"
require_relative "lita/message"
require_relative "lita/response"
require_relative "lita/http_route"
require_relative "lita/rack_app"
require_relative "lita/robot"
require_relative "lita/adapter"
require_relative "lita/adapters/shell"
require_relative "lita/handler"
require_relative "lita/handlers/authorization"
require_relative "lita/handlers/help"
require_relative "lita/handlers/web"
