class Command
  CLEAN_ENV = 'env -i HOME=$HOME LC_CTYPE=${LC_ALL:-${LC_CTYPE:-$LANG}} PATH=$PATH USER=$USER SSH_AUTH_SOCK=$SSH_AUTH_SOCK SSH_AGENT_PID=$SSH_AGENT_PID'.freeze

  def initialize
    @cwd = nil
    @clean = false
  end

  def cd(path='~')
    @cwd = path
    self
  end

  def clean(clean=true)
    @clean = clean
    self
  end

  def cap!(*args)
    '%{cd} %{clean} bundle exec cap %{args}' % {
      cd: cd_str,
      clean: clean_str,
      args: args.join(' '),
    }
  end

  def bundle_install!(environment)
    # Bundle install cannot install headers for specific gems (ex: 'sqlite')
    # Please install it on remote servers
    '%{cd} %{clean} bundle install --%{env} 2> /dev/null' % {
      cd: cd_str,
      clean: clean_str,
      env: environment,
    }
  end

  def ssh_agent!
    SETTINGS['ssh_agent_script']
  end

  def raw!(*commands)
    '%{cd} %{clean} bundle install %{commands}' % {
      cd: cd_str,
      clean: clean_str,
      commands: Command.and(*commands),
    }
  end

  def cat!(filename)
    '%{cd} %{clean} cat %{filename}' % {
      cd: cd_str,
      clean: clean_str,
      commands: Command.and(*commands),
    }
  end

  def self.and(commands*)
    commands.join(' && ')
  end

  protected

  def clean_str
    @clean ? CLEAN_ENV : ''
  end

  def cd_str
    @cwd ? ('cd "%s" 2> /dev/null &&' % @cwd) : ''
  end
end
