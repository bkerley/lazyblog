class BlogController < ApplicationController
  def index
    @posts = Post.
             order(created_at: :desc).
             limit(5)
  end

  def show
    @post = RiakPost.find(params[:id])
  end
end
