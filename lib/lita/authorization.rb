module Lita
  # Methods for querying and manipulating authorization groups.
  class Authorization
    attr_reader :config

    def initialize(config)
      @config = config
    end

    # Adds a user to an authorization group.
    # @param requesting_user [Lita::User] The user who sent the command.
    # @param user [Lita::User] The user to add to the group.
    # @param group [Symbol, String] The name of the group.
    # @return [Symbol] :unauthorized if the requesting user is not authorized.
    # @return [Boolean] true if the user was added. false if the user was
    #   already in the group.
    def add_user_to_group(requesting_user, user, group)
      return :unauthorized unless user_is_admin?(requesting_user)
      redis.sadd(normalize_group(group), user.id)
    end

    # Removes a user from an authorization group.
    # @param requesting_user [Lita::User] The user who sent the command.
    # @param user [Lita::User] The user to remove from the group.
    # @param group [Symbol, String] The name of the group.
    # @return [Symbol] :unauthorized if the requesting user is not authorized.
    # @return [Boolean] true if the user was removed. false if the user was
    #   not in the group.
    def remove_user_from_group(requesting_user, user, group)
      return :unauthorized unless user_is_admin?(requesting_user)
      redis.srem(normalize_group(group), user.id)
    end

    # Checks if a user is in an authorization group.
    # @param user [Lita::User] The user.
    # @param group [Symbol, String] The name of the group.
    # @return [Boolean] Whether or not the user is in the group.
    def user_in_group?(user, group)
      group = normalize_group(group)
      return user_is_admin?(user) if group == "admins"
      redis.sismember(group, user.id)
    end

    # Checks if a user is an administrator.
    # @param user [Lita::User] The user.
    # @return [Boolean] Whether or not the user is an administrator.
    def user_is_admin?(user)
      Array(config.robot.admins).include?(user.id)
    end

    # Returns a list of all authorization groups.
    # @return [Array<Symbol>] The names of all authorization groups.
    def groups
      redis.keys("*").map(&:to_sym)
    end

    # Returns a hash of authorization group names and the users in them.
    # @return [Hash] A map of +Symbol+ group names to {Lita::User} objects.
    def groups_with_users
      groups.reduce({}) do |list, group|
        list[group] = redis.smembers(group).map do |user_id|
          User.find_by_id(user_id)
        end
        list
      end
    end

    private

    # Ensures that group names are stored consistently in Redis.
    def normalize_group(group)
      group.to_s.downcase.strip
    end

    # A Redis::Namespace for authorization data.
    def redis
      @redis ||= Redis::Namespace.new("auth", redis: Lita.redis)
    end

    class << self
      # @deprecated Use {#add_user_to_group} instead.
      def add_user_to_group(requesting_user, user, group)
        Lita.logger.warn(
          "lita.core.deprecated",
          old_method: "Lita::Authorization.add_user_to_group",
          new_method: "Lita::Authorization#add_user_to_group"
        )
        new(Lita.config).add_user_to_group(requesting_user, user, group)
      end

      # @deprecated Use {#remove_user_from_group} instead.
      def remove_user_from_group(requesting_user, user, group)
        Lita.logger.warn(
          "lita.core.deprecated",
          old_method: "Lita::Authorization.remove_user_from_group",
          new_method: "Lita::Authorization#remove_user_from_group"
        )
        new(Lita.config).remove_user_from_group(requesting_user, user, group)
      end

      # @deprecated Use {#user_in_group?} instead.
      def user_in_group?(user, group)
        Lita.logger.warn(
          "lita.core.deprecated",
          old_method: "Lita::Authorization.user_in_group?",
          new_method: "Lita::Authorization#user_in_group?"
        )
        new(Lita.config).user_in_group?(user, group)
      end

      # @deprecated Use {#user_is_admin?} instead.
      def user_is_admin?(user)
        Lita.logger.warn(
          "lita.core.deprecated",
          old_method: "Lita::Authorization.user_is_admin?",
          new_method: "Lita::Authorization#user_is_admin?"
        )
        new(Lita.config).user_is_admin?(user)
      end

      # @deprecated Used {#groups} instead.
      def groups
        Lita.logger.warn(
          "lita.core.deprecated",
          old_method: "Lita::Authorization.groups",
          new_method: "Lita::Authorization#groups"
        )
        new(Lita.config).groups
      end

      # @deprecated Use {#groups_with_users} instead.
      def groups_with_users
        Lita.logger.warn(
          "lita.core.deprecated",
          old_method: "Lita::Authorization.groups_with_users",
          new_method: "Lita::Authorization#groups_with_users"
        )
        new(Lita.config).groups_with_users
      end
    end
  end
end
