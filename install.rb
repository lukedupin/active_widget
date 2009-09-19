require 'ftools'

puts ""
puts "Registering the widget mime type"
File.copy("#{File.dirname(__FILE__)}/../mime/mime_widget.rb",
            "#{File.dirname(__FILE__)}/../../../config/initializers/mime_widget.rb" )

puts ""
puts "Go into your controllers and change ApplicationController to ActiveWidgetController"
