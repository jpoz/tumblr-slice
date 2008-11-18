require File.dirname(__FILE__) + '/../spec_helper'

describe "TumblrSlice::Main (controller)" do
  
  # Feel free to remove the specs below
  
  before :all do
    Merb::Router.prepare { add_slice(:TumblrSlice) } if standalone?
  end
  
  after :all do
    Merb::Router.reset! if standalone?
  end
  
  it "should have access to the slice module" do
    controller = dispatch_to(TumblrSlice::Main, :index)
    controller.slice.should == TumblrSlice
    controller.slice.should == TumblrSlice::Main.slice
  end
  
  it "should have an index action" do
    controller = dispatch_to(TumblrSlice::Main, :index)
    controller.status.should == 200
    controller.body.should contain('TumblrSlice')
  end
  
  it "should work with the default route" do
    controller = get("/tumblr-slice/main/index")
    controller.should be_kind_of(TumblrSlice::Main)
    controller.action_name.should == 'index'
  end
  
  it "should work with the example named route" do
    controller = get("/tumblr-slice/index.html")
    controller.should be_kind_of(TumblrSlice::Main)
    controller.action_name.should == 'index'
  end
    
  it "should have a slice_url helper method for slice-specific routes" do
    controller = dispatch_to(TumblrSlice::Main, 'index')
    
    url = controller.url(:tumblr_slice_default, :controller => 'main', :action => 'show', :format => 'html')
    url.should == "/tumblr-slice/main/show.html"
    controller.slice_url(:controller => 'main', :action => 'show', :format => 'html').should == url
    
    url = controller.url(:tumblr_slice_index, :format => 'html')
    url.should == "/tumblr-slice/index.html"
    controller.slice_url(:index, :format => 'html').should == url
    
    url = controller.url(:tumblr_slice_home)
    url.should == "/tumblr-slice/"
    controller.slice_url(:home).should == url
  end
  
  it "should have helper methods for dealing with public paths" do
    controller = dispatch_to(TumblrSlice::Main, :index)
    controller.public_path_for(:image).should == "/slices/tumblr-slice/images"
    controller.public_path_for(:javascript).should == "/slices/tumblr-slice/javascripts"
    controller.public_path_for(:stylesheet).should == "/slices/tumblr-slice/stylesheets"
    
    controller.image_path.should == "/slices/tumblr-slice/images"
    controller.javascript_path.should == "/slices/tumblr-slice/javascripts"
    controller.stylesheet_path.should == "/slices/tumblr-slice/stylesheets"
  end
  
  it "should have a slice-specific _template_root" do
    TumblrSlice::Main._template_root.should == TumblrSlice.dir_for(:view)
    TumblrSlice::Main._template_root.should == TumblrSlice::Application._template_root
  end

end