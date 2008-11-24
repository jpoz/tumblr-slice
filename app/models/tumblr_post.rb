require 'hpricot'
require 'open-uri'
require 'cgi'
require 'time'

class TumblrSlice::TumblrPost
  include DataMapper::Resource

  property :id, Serial
  property :tumblr_id, Integer
  property :title, String, :length => 100
  property :big_url, String, :length => 100
  property :med_url, String, :length => 100
  property :small_url, String, :length => 100
  property :timestamp, DateTime
  property :text, Text
  property :post_type, String

  #has, n :comments
  
  def self.find_or_new(search_attributes, create_attributes = {})
    first(search_attributes) || new(search_attributes.merge(create_attributes))
  end

  def self.check(acct, options = {})
    return find_or_new(:tumblr_id => download(acct, :start => 0, :num => 1, :save => false ).first.tumblr_id ).new_record?
  end
    
  def self.download(acct, options = {})
    options = {:start => 0, :num => 15, :save => true}.merge(options)
    url = "http://#{acct}.tumblr.com/api/read?start=#{options[:start]}&num=#{options[:num]}"
    doc = Hpricot.XML(open(url))
    @posts= []
    (doc/"post").each do |tumble_post|
      post = find_or_new(
              :tumblr_id => tumble_post["id"], 
              :timestamp => DateTime.parse(tumble_post["date"]), 
              :post_type => tumble_post['type']
      )
      if post.new_record?
        begin
          send("extract_#{post.post_type}", tumble_post, post)
        rescue
          post.text = "#{post.post_type} not supported"
        end
        post.save if options[:save]
      end
      @posts << post
    end
    @posts
  end

  private

  def self.extract_photo(p, post = TumblrPost.new)
    post.big_url   = (p/"photo-url").first.inner_html if (p/"photo-url").first
    post.med_url   = post.big_url.to_s.gsub(/_500/, '_400')
    post.small_url = post.big_url.to_s.gsub(/_500/, '_75sq')
    post.text      = CGI::unescapeHTML((p/"photo-caption").first.inner_html.to_s) if (p/"photo-caption").first
  end

  def self.extract_regular(p, post = TumblrPost.new)
    post.title = CGI::unescapeHTML((p/"regular-title").first.inner_html.to_s) if (p/"regular-title").first
    post.text  = CGI::unescapeHTML((p/"regular-body").first.inner_html.to_s) if (p/"regular-body").first
  end
  
  def self.extract_quote(p, post = TumblrPost.new)
    post.title = CGI::unescapeHTML((p/"quote-source").first.inner_html.to_s) if (p/"quote-source").first
    post.text  = CGI::unescapeHTML((p/"quote-text").first.inner_html.to_s) if (p/"quote-text").first
  end
  
  def self.extract_video(p, post = TumblrPost.new)
    post.title = CGI::unescapeHTML((p/"video-caption").first.inner_html.to_s) if (p/"video-caption").first
    post.text  = CGI::unescapeHTML((p/"video-source").first.inner_html.to_s) if (p/"video-source").first
  end
  
  def self.extract_audio(p, post = TumblrPost.new)
    post.title = CGI::unescapeHTML((p/"audio-caption").first.inner_html.to_s) if (p/"audio-caption").first
    post.text  = CGI::unescapeHTML((p/"audio-player").first.inner_html.to_s) if (p/"audio-player").first
  end
  
  def self.extract_conversation(p, post = TumblrPost.new) ## this could also be prgrssvl nhncd to use conversation-lines
    post.title = CGI::unescapeHTML((p/"conversation-title").first.inner_html.to_s) if (p/"conversation-title").first
    post.text  = CGI::unescapeHTML((p/"conversation-text").first.inner_html.to_s) if (p/"conversation-text").first
  end
  
  def self.extract_link(p, post = TumblrPost.new)
    post.title = (p/"link-text").first.inner_html if (p/"link-text").first
    post.text  = (p/"link-url").first.inner_html if (p/"link-url").first
  end

  #### To-do: build other post types

end
