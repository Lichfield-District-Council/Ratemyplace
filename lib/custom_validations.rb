module ActiveRecord
  module Validations
    module ClassMethods
      
      #  validates_presence_of_at_least_one_field :foo, :bar 
      #    - require either foo or bar
      #  validates_presence_of_at_least_one_field :email, [:name, :address, :city, :state]
      #    - require email or mailing address
      def validates_presence_of_at_least_one_field(*attr_names)
        configuration = {:on => :create, :message => set_msg(attr_names)}
        configuration.update(attr_names.extract_options!)
        
        send(validation_method(configuration[:on]), configuration) do |record|
          found = false
          attr_names.each do |a|
            a = [a] unless a.is_a?(Array)
            found = true
            a.each do |attr|
              value = record.respond_to?(attr.to_s) ? record.send(attr.to_s) : record[attr.to_s]
              found = !value.blank?
            end
            break if found
          end
          record.errors.add(:base, configuration[:message]) unless found
        end
      end
      
      private
      
      def validation_method(on)
        case on
          when :save   then :validate
          when :create then :validate
          when :update then :validate
        end
      end
      
      def set_msg(attr_names)
        msg = attr_names.collect {|a| a.is_a?(Array) ? " (#{a.join(", ")}) " : a.to_s}.join(", ") +
              " can't all be blank: at least one must be filled in."
      end
    end
  end
end