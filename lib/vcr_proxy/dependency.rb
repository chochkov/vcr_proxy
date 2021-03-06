module VCRProxy
  module Dependency
    class << self

      def rails3?
        safe_check_gem('rails', '>= 3.0') && running_rails3?
      end

      private

      def running_rails3?
        defined?(Rails) && Rails.version.to_i == 3
      end

      def safe_check_gem(gem_name, version_string)
        if Gem::Specification.respond_to?(:find_by_name)
          Gem::Specification.find_by_name(gem_name, version_string)
        elsif Gem.respond_to?(:available?)
          Gem.available?(gem_name, version_string)
        end
      rescue Gem::LoadError
        false
      end
    end
  end
end
