User.create!(
  email: 'admin@gmail.com',
  password: 'password',
  password_confirmation: 'password',
  admin: true
)

users = []
3.times do
  user = User.create!(
    email: Faker::Internet.email,
    password: 'password',
    password_confirmation: 'password'

  )
  users << user
end

6.times do
  post = Post.create!(
    title: Faker::Book.title,
    content: Faker::Lorem.sentence(word_count: 10),
    user_id: users.sample&.id
  )
  p post
end