# Curly is a simple view system. Each view consists of two parts, a
# template and a presenter. The template is a simple string that can contain
# components in the format `{{refname}}`, e.g.
#
#   Hello {{recipient}},
#   you owe us ${{amount}}.
#
# The components will be converted into messages that are sent to the
# presenter, which is any Ruby object. Only public methods can be referenced.
# To continue the earlier example, here's the matching presenter:
#
#   class BankPresenter
#     def initialize(recipient, amount)
#       @recipient, @amount = recipient, amount
#     end
#
#     def recipient
#       @recipient.full_name
#     end
#
#     def amount
#       "%.2f" % @amount
#     end
#   end
#
# See Curly::Presenter for more information on presenters.
#
module Curly
  VERSION = "1.0.0"

  # Compiles a Curly template to Ruby code.
  #
  # template - The template String that should be compiled.
  #
  # Returns a String containing the Ruby code.
  def self.compile(template, presenter_class)
    Compiler.compile(template, presenter_class)
  end

  # Whether the Curly template is valid. This includes whether all
  # components are available on the presenter class.
  #
  # template        - The template String that should be validated.
  # presenter_class - The presenter Class.
  #
  # Returns true if the template is valid, false otherwise.
  def self.valid?(template, presenter_class)
    Compiler.valid?(template, presenter_class)
  end
end

require 'curly/compiler'
require 'curly/presenter'
require 'curly/template_handler'
require 'curly/railtie' if defined?(Rails)
