require 'erb'

  #This class provides an inline widget function that allows the attachment of code with views
class ActiveWidgetController < ApplicationController
    #This overloads the respond_to function to protect it from crashing
    #Whent he user is calling things as a widget
  def respond_to( &block )
    if @widget
      @active_widget = ActiveWidgetFormat.new if @active_widget.nil?
      block.call( @active_widget )
    else
      super( &block )
    end
  end

  # This method overloads render to catch any default widget options.
  # If we aren't rendering a widget, the method acts as a pass through
  def render( options = {}, extra_options = {}, &block )
    if @widget
      @active_widget = ActiveWidgetFormat.new if @active_widget.nil?
      @active_widget.load_args( options, extra_options || Hash.new )
    else
      super#( options, extra_options, &block )
    end
  end
  
  # This method has all the real magic.  Inside this we call our controller's
   # action and render out all of our data to a string
  def self.render( options = nil, extra_options = {}, &block )
    if     options.nil?
      options = { :action => :index }
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


    ### Call my action to generate instance variables
    obj = self.new
    obj.instance_variable_set('@widget', true);
    obj.send(options[:action])

    ### Store all the instance variables the action inside the class generated
    obj.instance_variables.each do |v| 
      instance_variable_set(v, obj.instance_variable_get(v))
    end

      #Update the user options with the respond_to options in the controller
      #If the user gave a conflicting option, we side with the user
    @active_widget.update_options!( options ) if @active_widget

      #Create the local variables passed by the user
    options[:locals].each do |k,v|
      instance_variable_set( "@#{k}", v )
    end if options[:locals].is_a? Hash

			#Get the extension we are gonig to render out
		case (options[:format] || :html).to_sym
		when :xml
			ext = 'xml'
    when :js
			ext = 'js'
    when :json
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

      #Now render out the string
    return ERB.new(File.open(filename).read).result(binding)
  end
end
