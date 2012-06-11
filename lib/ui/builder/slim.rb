require 'temple'
require 'slim/parser'
require 'slim/filter'
require 'slim/interpolation'
require 'ui'
require 'pp'

module UI
  module Builder
    module Slim


      class Generator < Temple::Generator
      end

      class Compiler < Temple::Filter

        TOPLEVEL_ELEMENTS = [:main_dialog, :popup_dialog]
        CONTAINER_ELEMENTS = [:vbox, :hbox]
        LEAF_ELEMENTS = [:push_button, :input_field]

        set_default_options :dictionary => 'self',
                            :partial => 'partial'

        def on_static(content)
          content.to_s
        end

        def on_multi(*exps)
          return compile(exps.first) if exps.size == 1
          result = [:multi]
          exps.each do |exp|
            exp = compile(exp)
            if exp.is_a?(Array) && exp.first == :multi
              result.concat(exp[1..-1])
            else
              result << exp
            end
          end
        end

        def on_slim_tag(name, attrs, body)    
          previous_parent = @current_parent

          if TOPLEVEL_ELEMENTS.include?(name.to_sym)
            obj = UI::Builder.send("create_#{name}".to_sym)
          elsif LEAF_ELEMENTS.include?(name.to_sym)
            text = compile(body)
            pp text
            obj = UI::Builder.send("create_#{name}".to_sym, @current_parent, text)
          elsif CONTAINER_ELEMENTS.include?(name.to_sym)
            obj = UI::Builder.send("create_#{name}".to_sym, @current_parent)
          else
            raise "Unknown element type"
          end
          @current_parent = obj
          compile(body)
          @current_parent = previous_parent
          obj
        end
      end

      class Generator
        def call(exp)
          exp
        end
      end

      class Engine < Temple::Engine
        use ::Slim::Parser, :file, :tabsize, :encoding, :shortcut, :default_tag
        use ::Slim::Interpolation
        filter :MultiFlattener
        use Compiler
        use(:Generator) { UI::Builder::Slim::Generator.new }
      end

    end
  end
end

module UI
  def self.slim(io)
    UI::Builder::Slim::Engine.new.call(io)
  end
end