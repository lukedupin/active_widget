require 'erb'

  #This class provides an inline widget function that allows the attachment of code with views
class ActiveWidgetController < ApplicationController
  def self.render( options = nil, extra_options = {}, &block )
    if     options.nil?
      raise "Can't deal with empty options yet, please provide an action name"
      options = { :template => default_template, :layout => true }
    elsif options == :update
      options = extra_options.merge({ :update => true })
    elsif options.is_a? String or options.is_a? Symbol
      case options.to_s.index('/')
      when 0
        extra_options[:file] = options.to_s
      when nil
        extra_options[:action] = options.to_s
      else
        extra_options[:template] = options.to_s
      end

        #Combine all options into a has
      options = extra_options
    elsif !options.is_a?(Hash)
      extra_options[:partial] = options
      options = extra_options
    end

			#Get the extension
		case
		when options[:xml]
			ext = 'xml'
    when options[:js]
			ext = 'js'
    when options[:json]
			ext = 'json'
		else
			ext = 'html'
		end

			#Get my controller
		cont = self.to_s.gsub(/([A-Z])/, '_\1').sub(/_/, '').sub(/_[^_]*$/, '').downcase

      #Figure out what file these guys are asking for
    if options[:partial]
			filename = File.join(RAILS_ROOT, 'app', 'views', cont, "_#{options[:partial]}.#{ext}.erb")
    elsif options[:action]
			filename = File.join(RAILS_ROOT, 'app', 'views', cont, "#{options[:action]}.#{ext}.erb")
    else
      raise 'Can\'t find a valid action to act on'
    end

      #Call my action to generate instance variables
    obj = self.new
    obj.instance_variable_set('@widget', true);
    obj.send(options[:action])

      #Store all the instance variables created from my logic class
    obj.instance_variables.each do |v| 
      instance_variable_set(v, obj.instance_variable_get(v))
    end

      #Create the local variables passed by the user
    options[:locals].each do |k,v|
      instance_variable_set( "@#{k}", v )
    end if options[:locals].is_a? Hash

      #Now render out the string
    return ERB.new(File.open(filename).read).result(binding)
  end
end