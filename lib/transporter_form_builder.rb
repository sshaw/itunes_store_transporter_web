require "options"
require "bootstrap_forms"

class TransporterFormBuilder < BootstrapForms::FormBuilder
  include Options

  def select_transport(*args)
    options = args.extract_options!
    options[:options] = TRANSPORTS
    options[:include_blank] = "Transporter's Default"
    name = args.shift || "transport"
    select name, options
  end

  def select_account(*args)
    options = args.extract_options!
    options[:options] = Array(args.shift).map { |a| [a.username, a.id] }
    options[:include_blank] = true unless options.include?(:include_blank)
    name = args.shift || "account_id"
    select name, options
  end

  def select_priority(*args)
    options = args.extract_options!
    options[:options] = PRIORITIES
    name = args.shift || "priority"
    select name, options
  end

  # TODO: revaluate :prompt & :label defaults
  def file_browser_field(name, options = {})
    prompt = options.delete(:prompt) || "Select #{name.to_s.titleize}"

    value = object.send(name)
    options[:value] = File.basename(value) if value

    # Fix Bootstrap forms so that it renders errors for uneditable_input
    options[:error] = object.errors[name].to_sentence if object.errors.include?(name)

    options[:id] = name
    options[:data] ||= {}
    options[:data][:content] = value
    options[:label] = name.to_s.titleize unless options.include?(:label)
    options[:label] << ":" # Conform to Padrino label quirk
    options[:help_block] = link_to(prompt, "#", :id => "open_file_browser_for_#{options[:id]}")

    uneditable_input(name, options) << hidden_field(name, :id => "selected_#{options[:id]}", :value => value)
  end

  def rate_field(*args)
    options = args.extract_options!
    options[:class]  = "input-small"
    options[:append] = "Kbps"
    options[:label]  = "Rate:" unless options.include?(:label)
    name = args.shift || "rate"
    text_field name, options
  end
end
