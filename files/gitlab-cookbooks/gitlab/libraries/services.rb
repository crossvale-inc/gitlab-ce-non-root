class Services
  SYSTEM_GROUP = 'system'.freeze
  DEFAULT_GROUP = 'default'.freeze
  SERVICE_CONFIG_TEMPLATE = { groups: [] }.freeze

  class << self
    def service_list
      @service_list ||= {
        'logrotate' =>          svc(groups: [DEFAULT_GROUP, SYSTEM_GROUP]),
        'node_exporter' =>      svc(groups: [DEFAULT_GROUP, SYSTEM_GROUP]),
        'gitlab_rails' =>       svc(groups: [DEFAULT_GROUP, 'rails']),
        'unicorn' =>            svc(groups: [DEFAULT_GROUP, 'rails']),
        'sidekiq' =>            svc(groups: [DEFAULT_GROUP, 'rails']),
        'gitaly' =>             svc(groups: [DEFAULT_GROUP, 'rails']),
        'gitlab_monitor' =>     svc(groups: [DEFAULT_GROUP, 'rails']),
        'gitlab_workhorse' =>   svc(groups: [DEFAULT_GROUP, 'rails']),
        'redis' =>              svc(groups: [DEFAULT_GROUP, 'redis']),
        'redis_exporter' =>     svc(groups: [DEFAULT_GROUP, 'redis']),
        'postgresql' =>         svc(groups: [DEFAULT_GROUP]),
        'nginx' =>              svc(groups: [DEFAULT_GROUP]),
        'prometheus' =>         svc(groups: [DEFAULT_GROUP]),
        'postgres_exporter' =>  svc(groups: [DEFAULT_GROUP]),
        'mailroom' =>           svc,
        'gitlab_pages' =>       svc,
        'mattermost' =>         svc,
        'mattermost_nginx' =>   svc,
        'pages_nginx' =>        svc,
        'registry' =>           svc,
      }
    end

    def system_services
      find_by_group(SYSTEM_GROUP)
    end

    def disable(*services, except: nil, force: false)
      exceptions = [except].flatten
      except.merge!(system_services.keys) unless force
      set_enabled(false, *services, except: exceptions)
    end

    def enable(*services, except: nil)
      set_enabled(true, *services, except: except)
    end

    def disable_group(*groups, except: nil, force: false)
      exceptions = [except].flatten
      exceptions << SYSTEM_GROUP unless force
      set_enabled_group(false, *groups, except: exceptions)
    end

    def enable_group(*groups, except: nil)
      set_enabled_group(true, *groups, except: except)
    end

    def find_by_group(group)
      services_list.select { |name, service| service.groups.include?(group) }
    end

    private

    def svc(config = {})
      SERVICE_CONFIG_TEMPLATE.dup.merge(config)
    end

    def set_enabled(enable, *services, except: nil)
      exceptions = [except].flatten
      services_list.each do |name|
        if (services.empty? || services.include?(name)) && !exceptions.include?(name)
          Gitlab[name]['enable'] = enable
        end
      end
    end

    def set_enabled_group(enable, *groups, except: nil)
      exceptions = [except].flatten
      services_list.select do |name, service|
        if (groups.empty? || !(groups & service.groups).empty?) && (exceptions & service.groups).empty?
          Gitlab[name]['enable'] = enable
        end
      end
    end
  end
end unless defined?(Services) # Prevent reloading during converge, so we can test
