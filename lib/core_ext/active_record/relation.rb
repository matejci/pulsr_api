class ActiveRecord::Relation
  def random
    offset(rand(count))
  end
end