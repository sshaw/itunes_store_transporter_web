require "options"
require "bootstrap_forms"

class TransporterFormBuilder < BootstrapForms::FormBuilder
  include Options

  def select_transport(name, options = {})
    options[:options] = TRANSPORTS
    options[:include_blank] = "Transporter's Default" 
    select name, options
  end
  
  def file_browser_field(name, options = {})
    prompt = options.delete(:prompt) || "Select #{name.to_s.titleize}"

    value = object.send(name)
    options[:value] = File.basename(value) if value

    options[:id] = name
    options[:data] ||= {}
    options[:data][:content] = value
    options[:label] = name.to_s.titleize unless options.include?(:label)    
    options[:label] << ":" # Conform to Padrino label quirk
    options[:help_block] = link_to(prompt, "#", :id => "open_file_browser_for_#{options[:id]}")
    
    uneditable_input(name, options) + hidden_field(name, :id => "selected_#{options[:id]}", :value => value)
  end

  def rate_field(name, options = {})
    options[:class]  = "input-small"
    options[:append] = "Kbps"
    options[:label]  = "Rate:" unless options.include?(:label)
    text_field name, options
  end
end
