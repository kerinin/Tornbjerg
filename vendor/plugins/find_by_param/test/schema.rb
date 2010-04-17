ActiveRecord::Schema.define(:version => 0) do

  create_table :posts, :force => true do |t|
    t.string        :title
    t.string          :permalink
  end
  
  create_table :articles, :force => true do |t|
    t.string        :title
  end

  create_table :users, :force => true do |t|
    t.string            :login
  end

  create_table :authors, :force => true do |t|
    t.string  :first_name
    t.string  :last_name
    t.string  :permalink
  end
end
