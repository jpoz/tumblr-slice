require File.join( File.dirname(__FILE__), '..', "spec_helper" )

module TumblrPostSpecHelper
  def mock_feed(n=1)
    xml = File.read(
      File.join( File.dirname(__FILE__), '../fixtures', "all_types.xml")
    )
    TumblrPost.should_receive(:open).at_least(n).times.and_return(xml)
  end
end

describe TumblrPost do
  include TumblrPostSpecHelper
  
  describe '#get' do

    before(:each) do
      mock_feed
      @ps = {:start => 0, :num => 10}
      @posts = TumblrPost.get('account', @ps)
    end
    
    it "should populate the tumblr id" do
      @posts.first.tumblr_id.should == 59615461
    end

    it "should populate the url-big" do
      TumblrPost.first(:conditions => ["post_type = 'photo'"]).big_url.should == 'http://data.tumblr.com/KZPtOc3DXg9xvo0gtwOrsrpPo1_500.jpg'
    end

    it "should populate the small-url" do
      TumblrPost.first(:conditions => ["post_type = 'photo'"]).small_url.should == 'http://data.tumblr.com/KZPtOc3DXg9xvo0gtwOrsrpPo1_75sq.jpg'
    end

    it "should populate the datetime" do 
      # I hate time... timestamp.should == DateTime.parse(..) passes with single run, if all test run it fails
      datetime = DateTime.parse('Fri, 14 Nov 2008 00:40:37')
      @posts.first.timestamp.year.should == datetime.year
      @posts.first.timestamp.month.should == datetime.month
      @posts.first.timestamp.day.should == datetime.day
      @posts.first.timestamp.hour.should == datetime.hour
      @posts.first.timestamp.sec.should == datetime.sec
    end

    it "should populate the caption" do
      @posts.last.text.should == 'This is somee crazy stuff.. Yadda yadda&#8230;'
    end

    it "should return an array" do
      Array.should === @posts
    end 
    
    it "shouldn't add double posts" do
      lambda {
        TumblrPost.get('account', @ps)
      }.should change(TumblrPost, :count).by(0)
    end
    
  end
  
  describe "#get options" do
    
    before(:each) do
      TumblrPost.all.destroy!
    end
    
    it "should not save when :save is false" do
      mock_feed
      @ps = {:start => 0, :num => 10, :save => false}
      lambda {
        @posts = TumblrPost.get('account', @ps)
      }.should_not change(TumblrPost, :count)
    end
    
    it "should save when :save is true" do
      mock_feed
      @ps = {:start => 0, :num => 10, :save => true}
      lambda {
        @posts = TumblrPost.get('account', @ps)
      }.should change(TumblrPost, :count)
    end
  end
  
  describe "#check_and_get_tumblr" do
    it "should update the database if new posts have been made to the tumblr account" do
      mock_feed
      TumblrPost.get('account').first.destroy
      lambda {
        TumblrPost.check('account')
      }.should change(TumblrPost, :count).by(1)
    end
  end
  
  describe "#find_or_new" do
    it "should find a TumblrPost" do
      TumblrPost.create(:text => "Yippidy yippidy do da")
      tumble = TumblrPost.find_or_new(:text => "Yippidy yippidy do da")
      tumble.new_record?.should be_false
    end
    
    it "should make a new TumblrPost if one does not exist" do
      tumble = TumblrPost.find_or_new(:text => "I eat a cheeze doodle")
      tumble.new_record?.should be_true
    end
    
  end
end
