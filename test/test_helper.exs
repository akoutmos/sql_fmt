Mix.shell(Mix.Shell.Process)
Application.put_env(:mix, :colors, enabled: false)

ExUnit.start()
