class TumblrSlice::TumblrPosts < TumblrSlice::Application
  # provides :xml, :yaml, :js
  TUMBLR_ACCOUNT = 'whoahbot'

  def index
    if TumblrPost.check(TUMBLR_ACCOUNT)
      TumblrPost.get(TUMBLR_ACCOUNT)
    end
    @tumblr_posts = TumblrPost.all(:order=> [:timestamp.desc])
    display @tumblr_posts
  end

  def show(id)
    @tumblr_post = TumblrPost.get(id)
    raise NotFound unless @tumblr_post
    display @tumblr_post
  end

  def new
    only_provides :html
    @tumblr_post = TumblrPost.new
    display @tumblr_post
  end

  def edit(id)
    only_provides :html
    @tumblr_post = TumblrPost.get(id)
    raise NotFound unless @tumblr_post
    display @tumblr_post
  end

  def create(tumblr_post)
    @tumblr_post = TumblrPost.new(tumblr_post)
    if @tumblr_post.save
      redirect resource(@tumblr_post), :message => {:notice => "TumblrPost was successfully created"}
    else
      message[:error] = "TumblrPost failed to be created"
      render :new
    end
  end

  def update(id, tumblr_post)
    @tumblr_post = TumblrPost.get(id)
    raise NotFound unless @tumblr_post
    if @tumblr_post.update_attributes(tumblr_post)
       redirect resource(@tumblr_post)
    else
      display @tumblr_post, :edit
    end
  end

  def destroy(id)
    @tumblr_post = TumblrPost.get(id)
    raise NotFound unless @tumblr_post
    if @tumblr_post.destroy
      redirect resource(:tumblr_posts)
    else
      raise InternalServerError
    end
  end

end # TumblrPosts
