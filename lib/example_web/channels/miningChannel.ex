defmodule ExampleWeb.RoomChannel do
    use Phoenix.Channel

    def join("miningChannel", _message, socket) do
      {:ok, socket}
    end
    
    def handle_in("startMining", %{}, socket) do
      randomNumber=Example.Main.miningProcedure(100)
      broadcast!(socket, "startMiningResponse", %{output: randomNumber})
      {:noreply, socket}
    end
end