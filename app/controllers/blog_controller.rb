class BlogController < ApplicationController
  def index
    @posts = Post.
             order(created_at: :desc).
             limit(5)
  end

  def show
    @post = Post.
            includes(comments: :user).
            where(id: params[:id]).
            first!
  end
end
