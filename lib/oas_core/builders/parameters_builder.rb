# frozen_string_literal: true

module OasCore
  module Builders
    class ParametersBuilder
      def initialize(specification)
        @specification = specification
        @parameters = []
      end

      def from_oas_route(oas_route)
        parameters_from_tags(tags: oas_route.tags(:parameter))

        oas_route.path_params&.map do |p|
          @parameters << ParameterBuilder.new(@specification).from_path(oas_route.path, p).build unless @parameters.any? { |param| param.name.to_s == p.to_s }
        end

        oas_route.tags(:parameter_ref)&.each do |ref_tag|
          @parameters << ref_tag.reference
        end

        self
      end

      def parameters_from_tags(tags:)
        tags.each do |t|
          parameter = Spec::Parameter.new(@specification)
          parameter.name = t.name
          parameter.in = t.location
          parameter.required = t.required
          parameter.schema = t.schema
          parameter.description = t.text
          @parameters << parameter
        end

        self
      end

      def build
        @parameters.map do |p|
          if p.is_a? OasCore::Spec::Reference
            p
          else
            @specification.components.add_parameter(p)
          end
        end
      end
    end
  end
end
