User.create!(
  email: 'admin@gmail.com',
  password: 'password',
  password_confirmation: 'password',
  admin: true
)

3.times do
  User.create!(
    email: Faker::Internet.email,
    password: 'password',
    password_confirmation: 'password'

  )
end

6.times do
  Post.create!(
    title: Faker::Book.title,
    content: Faker::Lorem.sentence(word_count: 10),
    user_id: User.where.not(admin: true).sample.id,
    published: [true, false].sample
  )
end

10.times do
  Comment.create!(
    content: Faker::Lorem.sentence(word_count: 10),
    user_id: User.where.not(admin: true).sample.id,
    post_id: Post.all.sample.id
  )
end