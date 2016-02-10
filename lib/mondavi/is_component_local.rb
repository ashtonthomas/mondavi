module Mondavi
  class IsComponentLocal
    include Operation

    def initialize(target_concept:)
      @target_concept = target_concept
    end

    def call()
      # TODO: May need to make this more robust
      impl = @target_concept.to_s.gsub("Api", "ApiImpl")
      Object.const_get(impl).present?
    rescue NameError => e
      false
    end

    private

    attr_accessor :target_concept
  end
end
