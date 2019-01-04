defmodule ExampleWeb.TransactionChannel do
    use Phoenix.Channel

    def join("transactionChannel", _message, socket) do
      {:ok, socket}
    end
    
    def handle_in("transactionProcedure", %{"sender" => senderProcess, "receiver" => receiverProcess, "amount" => amount, "fee" => fee}, socket) do
      answer=Example.Main.startTransaction(senderProcess,receiverProcess,amount,fee)
      broadcast!(socket, "transactionResponse", %{output: answer})
      {:noreply, socket}
    end
end