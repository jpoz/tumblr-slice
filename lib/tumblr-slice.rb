if defined?(Merb::Plugins)

  $:.unshift File.dirname(__FILE__)

  load_dependency 'merb-slices'
  Merb::Plugins.add_rakefiles "tumblr-slice/merbtasks", "tumblr-slice/slicetasks", "tumblr-slice/spectasks"

  # Register the Slice for the current host application
  Merb::Slices::register(__FILE__)
  
  # Slice configuration - set this in a before_app_loads callback.
  # By default a Slice uses its own layout, so you can swicht to 
  # the main application layout or no layout at all if needed.
  # 
  # Configuration options:
  # :layout - the layout to use; defaults to :tumblr-slice
  # :mirror - which path component types to use on copy operations; defaults to all
  Merb::Slices::config[:tumblr_slice][:layout] ||= :tumblr_slice
  Merb::Slices::config[:tumblr_slice][:account] ||= "poz"
  
  # All Slice code is expected to be namespaced inside a module
  module TumblrSlice
    
    # Slice metadata
    self.description = "TumblrSlice is a Merb slice which integrates your Tumblr account into your awesome merb app!"
    self.version = "0.0.2"
    self.author = "James Pozdena"
    
    # Stub classes loaded hook - runs before LoadClasses BootLoader
    # right after a slice's classes have been loaded internally.
    def self.loaded
    end
    
    # Initialization hook - runs before AfterAppLoads BootLoader
    def self.init
    end
    
    # Activation hook - runs after AfterAppLoads BootLoader
    def self.activate
    end
    
    # Deactivation hook - triggered by Merb::Slices.deactivate(TumblrSlice)
    def self.deactivate
    end
    
    # Setup routes inside the host application
    #
    # @param scope<Merb::Router::Behaviour>
    #  Routes will be added within this scope (namespace). In fact, any 
    #  router behaviour is a valid namespace, so you can attach
    #  routes at any level of your router setup.
    #
    # @note prefix your named routes with :tumblr_slice_
    #   to avoid potential conflicts with global named routes.
    def self.setup_router(scope)
      scope.resources :tumblr_posts
      scope.match('/index(.:format)').to(:controller => 'main', :action => 'index').name(:index)
      scope.match('/').to(:controller => 'main', :action => 'index').name(:home)
    end
    
  end
  
  # Setup the slice layout for TumblrSlice
  #
  # Use TumblrSlice.push_path and TumblrSlice.push_app_path
  # to set paths to tumblr-slice-level and app-level paths. Example:
  #
  # TumblrSlice.push_path(:application, TumblrSlice.root)
  # TumblrSlice.push_app_path(:application, Merb.root / 'slices' / 'tumblr-slice')
  # ...
  #
  # Any component path that hasn't been set will default to TumblrSlice.root
  #
  # Or just call setup_default_structure! to setup a basic Merb MVC structure.
  TumblrSlice.setup_default_structure!
  
  # Add dependencies for other TumblrSlice classes below. Example:
  # dependency "tumblr-slice/other"
  
end