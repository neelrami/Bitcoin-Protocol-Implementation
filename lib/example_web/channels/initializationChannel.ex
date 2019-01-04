defmodule ExampleWeb.InitChannel do
    use Phoenix.Channel

    def join("initializationChannel", _message, socket) do
      {:ok, socket}
    end
    
    def handle_in("initProcesses", %{}, socket) do
      recentBlock=Example.Main.startBitcoin(100)
      broadcast!(socket, "initProcessesResponse", %{output: recentBlock})
      {:noreply, socket}
    end
end