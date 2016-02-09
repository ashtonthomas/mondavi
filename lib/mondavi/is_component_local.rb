class IsComponentLocal
  include Operation

  def initialize(target_concept:)
    @target_concept = target_concept
  end

  def call()
    impl = @target_concept.to_s.gsub("Component", "ComponentImpl")
    Object.const_get(impl).present?
  rescue NameError => e
    false
  end

  private

  attr_accessor :target_concept

end
