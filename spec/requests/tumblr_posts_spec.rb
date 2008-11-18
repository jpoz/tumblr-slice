require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a tumblr_post exists" do
  TumblrPost.all.destroy!
  request(resource(:tumblr_posts), :method => "POST", 
    :params => { :tumblr_post => { :id => nil }})
end

describe "resource(:tumblr_posts)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:tumblr_posts))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of tumblr_posts" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a tumblr_post exists" do
    before(:each) do
      @response = request(resource(:tumblr_posts))
    end
    
    it "has a list of tumblr_posts" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      TumblrPost.all.destroy!
      @response = request(resource(:tumblr_posts), :method => "POST", 
        :params => { :tumblr_post => { :id => nil }})
    end
    
    it "redirects to resource(:tumblr_posts)" do
      @response.should redirect_to(resource(TumblrPost.first), :message => {:notice => "tumblr_post was successfully created"})
    end
    
  end
end

describe "resource(@tumblr_post)" do 
  describe "a successful DELETE", :given => "a tumblr_post exists" do
     before(:each) do
       @response = request(resource(TumblrPost.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:tumblr_posts))
     end

   end
end

describe "resource(:tumblr_posts, :new)" do
  before(:each) do
    @response = request(resource(:tumblr_posts, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@tumblr_post, :edit)", :given => "a tumblr_post exists" do
  before(:each) do
    @response = request(resource(TumblrPost.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@tumblr_post)", :given => "a tumblr_post exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(TumblrPost.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @tumblr_post = TumblrPost.first
      @response = request(resource(@tumblr_post), :method => "PUT", 
        :params => { :tumblr_post => {:id => @tumblr_post.id} })
    end
  
    it "redirect to the article show action" do
      @response.should redirect_to(resource(@tumblr_post))
    end
  end
  
end

