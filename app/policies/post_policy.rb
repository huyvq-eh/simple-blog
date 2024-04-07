class PostPolicy < ApplicationPolicy
  def destroy?
    record.user == user
  end

  def update?
    record.user == user
  end

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(published: true)
      end

    end
  end
end
