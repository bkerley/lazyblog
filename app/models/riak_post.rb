class RiakPost
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_accessor :id, :name, :body, :user_id, :created_at, :updated_at
  attr_accessor :comments

  attr_accessor :robject

  def self.find(id)
    existing_blob = bucket.get id.to_s
    existing_data = existing_blob.data.deep_symbolize_keys
    new(existing_data).tap do |created|
      created.robject = existing_blob
    end
  end

  def self.from_post(post)
    existing_blob = bucket.get_or_new(post.id.to_s)
    existing_data = existing_blob.data.try(:deep_symbolize_keys) || {}
    merged_data = existing_data.merge(
      post.as_json(include: {
                     comments: {
                       include: :user }}))
    new(merged_data).tap do |created|
      created.robject = existing_blob
    end
  end

  def initialize(hash)
    symbolized = hash.deep_symbolize_keys
    self.id = symbolized[:id]
    self.name = symbolized[:name]
    self.body = symbolized[:body]
    self.user_id = symbolized[:user_id]
    self.created_at = symbolized[:created_at]
    self.updated_at = symbolized[:updated_at]
    self.comments = symbolized[:comments]
  end

  def to_hash
    {
      name: name,
      body: body,
      user_id: user_id,
      created_at: created_at,
      updated_at: updated_at,
      comments: comments
    }
  end

  def save
    self.robject ||= bucket.get_or_new(id.to_s)
    existing_data = robject.data || {}
    merged = existing_data.merge self
    robject.data = merged
    robject.store && true
  end

  def persisted?
    !robject.data.nil?
  end

  def comments
    @comments.map{ |c| Comment.new c }
  end

  def created_at
    return @created_at unless @created_at.is_a? String

    @created_at = Time.zone.parse @created_at

  end

  def updated_at
    return @updated_at unless @updated_at.is_a? String

    @updated_at = Time.zone.parse @updated_at
  end

  class Comment
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    attr_accessor :body, :user

    def initialize(h)
      self.body = h[:body]
      self.user = User.new h[:user]
    end
  end

  class User
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    attr_accessor :username

    def initialize(h)
      self.username = h[:username]
    end
  end

  private

  def self.bucket
    client.bucket 'posts'
  end

  def self.client
    RIAK_CLIENT
  end
end
