class Post < ActiveRecord::Base
  belongs_to :user
  has_many :comments

  def riak_post
    RiakPost.from_post self
  end
end
