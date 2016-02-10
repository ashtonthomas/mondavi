module Mondavi
  module Api
    mattr_accessor :mount_url_prefix

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def url_prefix(url_prefix)
        mount_url_prefix = url_prefix
      end

      # def url_prefix
      #   mount_url_prefix || '/foo/bar'
      # end
    end
  end
end
