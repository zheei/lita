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

  class << self
    # The global registry of adapters.
    # @return [Hash] A map of adapter keys to adapter classes.
    def adapters
      @adapters ||= {}
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
    # @return [Lita::Config] The Lita configuration object.
    def config
      Lita.logger.warn(I18n.t("lita.core.global_config_deprecation"))

      if robots.empty?
        default_robot_config
      else
        robots.first.config
      end
    end

    # Yields the global configuration object. Called by the user in a
    # lita_config.rb file.
    # @yieldparam [Lita::Configuration] config The global configuration object.
    # @return [void]
    def configure
      Lita.logger.warn(I18n.t("lita.core.global_configure_deprecation"))
      yield config
    end

    def configure_robot
      new_config = Config.default_config
      yield config
      robots << Robot.new(new_config)
    end

    # Clears the global configuration object. The next call to {Lita.config}
    # will create a fresh config object.
    # @return [void]
    def clear_config
      @default_robot_config = nil
    end

    # The global Logger object.
    # @return [::Logger] The global Logger object.
    def logger
      @logger ||= Logger.get_logger(default_robot_config.robot.log_level)
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
        Robot.new(default_robot_config).run
      else
        robots.each { |robot| robot.run }
      end
    end

    private

    def default_robot_config
      @default_robot_config ||= Config.default_config
    end

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
