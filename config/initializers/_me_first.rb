# Rails.application.config.middleware.use OmniAuth::Builder do
#   provider(
#     :auth0,
#     ENV['AUTH0_CLIENT_ID'],
#     ENV['AUTH0_CLIENT_SECRET'],
#     ENV['AUTH0_CLIENT_SECRET'],
#     ENV['AUTH0_NAMESPACE'],
#     callback_path: "http://local.drive.vote:3000/auth/auth0/callback"
#   )
# end