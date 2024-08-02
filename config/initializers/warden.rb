Rails.application.config.middleware.use Warden::Manager do |warden_config|
  warden_config.default_strategies :password
  warden_config.default_scope = :user

  warden_config.failure_app = ->(env) do
    env["REQUEST_METHOD"] = "GET"
    SessionsController.action(:new).call(env)
  end

  warden_config.serialize_into_session do |user|
    user.id
  end

  warden_config.serialize_from_session do |id|
    User.find(id)
  end
end
