module UserRoles
  extend ActiveSupport::Concern

  private

  def update_user_roles(params)
    # https://github.com/RolifyCommunity/rolify/issues/246
    # get just the global roles
    Role.global.each do |role|
      role_name = role.name.to_sym
      if params[role_name] == "1"
        @user.grant( role_name )
      elsif params[role_name] == "0"
        @user.revoke( role_name )
      end
    end
    return true
  end
end