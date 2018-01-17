require_relative 'attribute'
require_relative 'attribute_collection'
require_relative '../constants_to_methods_exposer'

module Krudmin
  module ResourceManagers
    class Base
      include Enumerable
      extend Krudmin::ConstantsToMethodsExposer

      delegate :each, :total_pages, :current_page, :limit_value, to: :items

      MODEL_CLASSNAME = nil
      LISTABLE_ATTRIBUTES = []
      EDITABLE_ATTRIBUTES = []
      SEARCHABLE_ATTRIBUTES = []
      DISPLAYABLE_ATTRIBUTES = []
      LISTABLE_ACTIONS = [:show, :edit, :destroy]
      ORDER_BY = []
      LISTABLE_INCLUDES = []
      RESOURCE_INSTANCE_LABEL_ATTRIBUTE = nil
      RESOURCE_LABEL = ""
      RESOURCES_LABEL = ""
      ATTRIBUTE_TYPES = {}
      PRESENTATION_METADATA = {}

      constantized_methods :searchable_attributes, :resource_label, :resources_label, :model_classname, :listable_actions, :order_by, :listable_includes, :resource_instance_label_attribute, :presentation_metadata, :displayable_attributes

      def field_for(field, model = nil, root: nil)
        resource_attributes.attribute_for(field, root).new_field(model)
      end

      def model_label(given_model)
        given_model.send(resource_instance_label_attribute)
      end

      def self.editable_attributes
        new.editable_attributes
      end

      def self.displayable_attributes
        new.displayable_attributes
      end

      def label_for(given_model)
        given_model.send(resource_instance_label_attribute)
      end

      def items
        @items ||= list_scope
      end

      def scope
        model_class.all
      end

      def list_scope
        scope.includes(listable_includes).order(order_by)
      end

      def model_class
        @model_class ||= model_classname.constantize
      end

      def self.model_class
        self::MODEL_CLASSNAME.constantize
      end

      private

      delegate :attribute_types, :permitted_attributes, :editable_attributes, :listable_attributes, :searchable_attributes, :grouped_attributes, :displayable_attributes, to: :resource_attributes

      def resource_attributes
        @resource_attributes ||= Krudmin::ResourceManagers::AttributeCollection.new(
                                                model_class,
                                                self.class::ATTRIBUTE_TYPES,
                                                self.class::EDITABLE_ATTRIBUTES,
                                                self.class::LISTABLE_ATTRIBUTES,
                                                self.class::SEARCHABLE_ATTRIBUTES,
                                                self.class::DISPLAYABLE_ATTRIBUTES,
                                                self.class::PRESENTATION_METADATA)
      end
    end
  end
end
