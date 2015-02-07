# -*- coding: utf-8 -*-

class RailsDataExplorer
  module Utils

    # Responsibilities:
    #  * Map an input value to a color on a color scale.
    #
    class ColorScale

      def initialize
        @points = {
          -1 => Color::RGB::Red,
          -0.1 =>  Color::RGB::Black,
          0.1 =>  Color::RGB::Black,
          1 => Color::RGB::Green,
        }
        @gradient = Interpolate::Points.new(@points)
        @gradient.blend_with {|color, other, balance|
          other.mix_with(color, balance * 100.0)
        }
      end

      def compute(input)
        @gradient.at(input).html
      end

      def demo
        "<ul>".html_safe +
        (-1).step(1, 0.1).map { |e|
          color = compute(e)
          %(<li style="color: #{ color }">#{ e } (#{ color })</li>)
        }.join.html_safe +
        "</ul>".html_safe
      end

    end
  end
end
