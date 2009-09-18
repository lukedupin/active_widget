class ActiveWidgetFormat
  attr_accessor :options, :extra_options

    #Ensure my that options are always vald hashes
  def initialize
    @options = Hash.new
    @extra_options = Hash.new
  end

    #Provide a widget format to the respond_to block inside controllers
  def widget( options = {}, extra_options = {} )
    @options = options
    @extra_options = extra_options
  end

    #Returns the merged options to ... someone
  def update_options!( options )
    options.merge!(@options)
    options = @extra_options.merge( options)
  end

    #Keeps us from crashing
  def method_missing( sym, *args )
  end
end
