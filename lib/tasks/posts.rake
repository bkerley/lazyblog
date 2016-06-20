namespace :posts do
  desc "Copy posts to Riak"
  task :riak_migrate => :environment do
    Post.all.each{ |p| p.riak_post.save }
  end
end
