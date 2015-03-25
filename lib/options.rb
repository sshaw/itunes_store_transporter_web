module Options
  TRANSPORTS = %w[Aspera Signiant DAV]
  PRIORITIES = %w[normal high low next].map { |e| [ e.titleize, e ] }

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
          validate :check_package, :unless => lambda { |form| form.package.blank? }
        end
      end

      private
      def contains_packages?(package)
        Dir[ File.join(package, "*.itmsp") ].any? { |path| File.directory?(path) }
      end

      def check_package
        if batch == "1" && !package.end_with?(".itmsp")
          errors[:package] << 'does not contain any ".itmsp" directories' unless contains_packages?(package)
        elsif !package.end_with?(".itmsp")
          errors[:package] << 'must end with ".itmsp"'
        end
      end
    end
  end
end
