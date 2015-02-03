require 'rltk'

module Curly
  class Lexer < RLTK::Lexer

    rule /{{/, :default do
      push_state :expression
      :EXPRST
    end

    rule /#if/, :expression do
      :IF
    end

    rule /\/if/, :expression do
      :IFCLOSE
    end

    rule /#unless/, :expression do
      :UNLESS
    end

    rule /\/unless/, :expression do
      :UNLESSCLOSE
    end

    rule /#each/, :expression do
      :EACH
    end

    rule /\/each/, :expression do
      :EACHCLOSE
    end

    rule /else/, :expression do
      :ELSE
    end

    rule /([A-Za-z][\w\.]*\??)/, :expression do |name|
      [ :IDENT, name ]
    end

    rule /\s+/, :expression do
      :WHITE
    end

    rule /}}/, :expression do
      pop_state
      :EXPRE
    end

    rule /\!/, :expression do
      push_state :comment
      :BANG
    end

    rule /([^}}]*)/, :comment do |comment|
      pop_state
      [ :COMMENT, comment ]
    end

    rule /.*?(?={{|\z)/m, :default do |output|
      [ :OUT, output ]
    end
  end
end
