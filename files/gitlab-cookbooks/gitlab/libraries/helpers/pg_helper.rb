require_relative 'base_pg_helper'

# Helper class to interact with bundled PostgreSQL instance
class PgHelper < BasePgHelper
  # internal name for the service (node['gitlab'][service_name])
  def service_name
    'postgresql'
  end

  # command wrapper name
  def service_cmd
    'gitlab-psql'
  end

  def public_attributes
    # Attributes which should be considered ok for other services to know
    attributes = %w(
      data_dir
      unix_socket_directory
      port
    )

    {
      'gitlab' => {
        service_name => node['gitlab'][service_name].select do |key, value|
                          attributes.include?(key)
                        end
      }
    }
  end
end
