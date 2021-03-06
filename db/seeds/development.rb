# db/seeds/development.rb

include Sprig::Helpers

Sprig.adapter = :mongoid

begin
  print 'Seeding database...'

  if User.count == 0
    email = 'aina.sahalin@zeon.space'
    crypt = '$2a$10$FMT8IAxJj3Z.XQfJiw6nLOrAnl/Upf9I007L5Or7lHJ5MfQQmtOHe'

    user = User.new :email => email, :encrypted_password => crypt
    user.save :validate => false

    raise Mongoid::Errors::Validations.new(user.tap &:destroy) unless user.valid?
  end # if

  sprig_models = [Setting, Directory, Page, Blog, BlogPost]
  sprig_models.each do |model_class|
    model_class.destroy_all
  end # each

  sprig sprig_models
rescue StandardError
  puts "error!\n"

  raise
end # begin-rescue

puts "success!\n\nObjects:"

[Setting, User, Directory, Page, Blog, BlogPost].each do |collection|
  puts "- #{collection.name}: #{collection.count}"
end
