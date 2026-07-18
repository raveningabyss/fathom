# frozen_string_literal: true

InertiaRails.configure do |config|
  config.version = ViteRuby.digest
  # History encryption needs window.crypto.subtle, which only exists in secure
  # contexts — http://admin.lvh.me in development is not one.
  config.encrypt_history = Rails.env.production?
  config.always_include_errors_hash = true
  config.use_script_element_for_initial_page = true
  config.use_data_inertia_head_attribute = true
  config.default_render = true
  config.component_path_resolver = ->(path:, action:) do
    "#{path}/#{action.camelize}"
  end
end
