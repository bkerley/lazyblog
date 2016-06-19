# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

users = 10.times.map do |n|
  User.create username: "user-#{n}", password_digest: "x"
end

10.times.each do |n|
  p = Post.create name: "Post #{n}", body: n.to_s

  rand(20).times do |c|
    Comment.create post_id: p.id, user_id: users.sample, body: "asdf"
  end
end
