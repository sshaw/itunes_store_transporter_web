module Options
  TRANSPORTS = %w[Aspera Signiant DAV]

  module Validations
    module Upload
      def self.included(obj)
        obj.class_eval do 
          include ActiveModel::Validations

          validates_inclusion_of :transport, :in => TRANSPORTS, :allow_nil => true, :allow_blank => true    
          validates_numericality_of :rate, :only_integer => true, :greater_than => 0, :unless => lambda { |form| form.rate.blank? }
        end
      end
    end
    
    module Package
      def self.included(obj)
        obj.class_eval do 
          include ActiveModel::Validations

          validates_presence_of :package
          validate :check_package_suffix, :unless => lambda { |form| form.package.blank? }
        end
      end

      private
      def check_package_suffix
        unless package.to_s.end_with?(".itmsp")
          errors[:package] << 'must end with ".itmsp"'
        end
      end
    end
  end
end
