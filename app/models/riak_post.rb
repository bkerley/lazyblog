class RiakPost < Hashie::Mash
  attr_accessor :robject

  def self.find(id)
    existing_blob = bucket.get id.to_s
    new(existing_blob.data).tap do |created|
      created.robject = existing_blob
    end
  end

  def self.from_post(post)
    existing_blob = bucket.get_or_new(post.id.to_s)
    existing_data = existing_blob.data || {}
    merged_data = existing_data.merge post.as_json(include: %i{user comments})
    new(merged_data).tap do |created|
      created.robject = existing_blob
    end
  end

  def save
    self.robject ||= bucket.get_or_new(id.to_s)
    existing_data = robject.data || {}
    merged = existing_data.merge self
    robject.data = merged
    robject.store && true
  end

  private

  def self.bucket
    client.bucket 'posts'
  end

  def self.client
    RIAK_CLIENT
  end
end
