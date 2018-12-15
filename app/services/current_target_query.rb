class TargetQuery
  def initialize(user)
    @user = user
  end

  def call
    Actions::Target
        .for_user(@user)
        .live
        .current
        .to_a
  end
end
