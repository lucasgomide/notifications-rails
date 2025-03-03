# frozen_string_literal: true

require 'active_support'
require 'hashie'

class HashieMashStoredAsJson < Hashie::Mash
  def self.dump(obj)
    ActiveSupport::JSON.encode(obj.to_h)
  end

  def self.load(json)
    new(json ? ActiveSupport::JSON.decode(json) : {})
  end
end

module NotificationSettings
  module Settings
    extend ActiveSupport::Concern

    included do
      before_validation :build_settings

      if ActiveRecord.gem_version >= Gem::Version.new('7.0.0')
        serialize :settings, coder: HashieMashStoredAsJson, type: HashieMashStoredAsJson
      else
        serialize :settings, HashieMashStoredAsJson
      end

      include NotificationSettings::Settings::InstanceMethods
    end

    module InstanceMethods
      private

      def build_settings
        return if settings.present? && settings.is_a?(Hashie::Mash)

        self.settings = HashieMashStoredAsJson.new
      end
    end
  end
end
