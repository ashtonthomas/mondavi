module Mondavi
  module RequestRouter
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def register_get(method, *declared_url_variables)
        define_singleton_method(method) do |**supplied_url_variables|
          @@service_document = nil

          # check parameters
          declared_url_variables.each do |required_url_variable|
            if !supplied_url_variables.keys.include?(required_url_variable)
              raise ArgumentError.new("key :#{required_url_variable} missing in call to :#{method} on #{self}")
            end
          end

          ensure_service_document

          is_local = IsComponentLocal.call(target_concept: self)

          if is_local
            # mock request and satisfy locally
            issue_local_request(
              http_verb: 'GET',
              urn_path: urn_path(method, supplied_url_variables)
            )
          else
            # issue external request
            # binding.pry # todo

            # Request and LocalRequest

            # note to self:
            # if component_index => supplied_url_variables[:url] + [:urn_path]

            # will need to get the url from svc-doc

            issue_external_request(
              http_verb: 'GET',
              url: url(method, supplied_url_variables),
              urn_path: urn_path(method, supplied_url_variables)
            )

          end

        end
        # not sure why I need this in pact_router
        # self.def_delegator self, method, method
      end

      def index?
        self == IndexComponent::IndexApi
      end

      def component_index?
        self.to_s.match(/::.*IndexApi$/).present?
      end

      def urn_path(method, supplied_url_variables)
        return "/index" if index?
        return supplied_url_variables[:urn_path] if component_index?

        # @@service_document should never have a representer
        # so it will just be a hashie::mash
        details = @@service_document.concepts[self.to_s][method]

        path = details.urn_path_template

        # look at each_with_object
        supplied_url_variables.each do |url_variable_key, url_variable_value|
          path.gsub!(":#{url_variable_key}", url_variable_value.to_s)
        end

        path
      end

      def url(method, supplied_url_variables)
        return "https://chi-winery.herokuapp.com" if index?
        return supplied_url_variables[:url] if component_index?

        details = @@service_document.concepts[self.to_s][method]
        url = details.url_template

        # look at each_with_object
        # maybe we change from url_variable.. to request or 'uri'
        supplied_url_variables.each do |url_variable_key, url_variable_value|
          url.gsub!(":#{url_variable_key}", url_variable_value.to_s)
        end

        url
      end

      def issue_external_request(http_verb: nil, url: nil, urn_path: nil)
        conn = Faraday.new(:url => url) do |faraday|
          faraday.request  :url_encoded             # form-encode POST params
          faraday.response :logger                  # log requests to STDOUT
          faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
        end

        # binding.pry
        # response = conn.get urn_path
        # response.body
      end

      def issue_local_request(http_verb: nil, urn_path: nil)
        env = {}
        env['rack.input'] = Puma::NullIO.new

        env['REQUEST_METHOD'] = http_verb
        env['REQUEST_PATH'] = urn_path
        env['REQUEST_URI'] = urn_path
        env['PATH_INFO'] = urn_path

        response = ApplicationApi.call(env)

        status = response[0]
        header = response[1]
        body = response[2].body.first

        begin
          extract_representer = self.to_s.gsub(/^.*::/, '').gsub('Api', 'Representer')
          representer = Object.const_get(extract_representer)

          struct = OpenStruct.new
          struct.extend(WineRepresenter)
          struct.from_json(body)
        rescue NameError => e
          # Representer doesn't exist, use Hashie::Mash
          # TODO could get back errors (http, not-found etc)

          # TODO
          # Looks like representers are serializing json
          # and index is not
          begin
            Hashie::Mash.new(JSON.parse(JSON.load(body)))
          rescue TypeError => e
            Hashie::Mash.new(JSON.parse(body))
          end

        end
      end

      # I can't make too many assumptions around "_should_"
      # because we will probably break those assumptions immediately: hello
      # there should be no _id_ for a post
      def post(url_variables:, body:)
        ensure_service_document

      end

      # id _should_ be included in the url_variables
      #
      def put(id:, url_variables:, body:)
        ensure_service_document
      end

      def ensure_service_document
        return if (index? || component_index?)

        if @@service_document.nil? || service_document_expired?
          @@service_document = IndexComponent::IndexApi.get
        end
      end

      def service_document_expired?
        return true unless @service_document
        Time.parse(@@service_document.requested_at) < (Time.now - 24.hours)
      end

    end
  end
end
