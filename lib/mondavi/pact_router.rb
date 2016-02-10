# Should be used in test (always) and dev (when call is external)
module Mondavi
  module PactRouter

    def self.included(base)
      base.mattr_accessor :pacts
      base.pacts = Hashie::Mash.new
      base.extend(ClassMethods)
    end

    module ClassMethods
      def pact_for(concept)
        is_test = ENV['RACK_ENV'] == 'test'
        is_external = !IsComponentLocal.call(target_concept: concept)

        if is_test || is_external
          mock(concept)
        end
      end

      def mock(concept)
        concept.extend(SingleForwardable)

        # override the methods dynamically defined methods
        # (defined in RequestRouter using the declarations in the component api)
        concept.methods(false).each do |method|
          define_singleton_method(method) do |args|
            stub = extract_stub(self, concept, method, args)

            representer = stub.representer
            response = stub.response

            return extract_concept(representer, response)
          end

          concept.def_delegator self, method, method
        end
      end

      def extract_stub(pact_class, concept, method, args)
        parameter_string = args.to_s

        if !pacts.has_key?(method) || !pacts[method].has_key?(parameter_string)
          raise "#{pact_class} does not have #{concept} pact for method ':#{method}' with id key: '#{parameter_string}'"
        end

        pacts[method][parameter_string]
      end

      def extract_concept(representer, response)
        struct = OpenStruct.new
        struct.extend(representer)
        struct.from_hash(response)
      end

      def pact method_name, parameter_string, stub
        pacts[method_name.to_s] = { parameter_string => stub }
      end
    end
  end
end
