defmodule Example.UTXO do
    alias Example.{UTXO}
    @type t :: %__MODULE__{
        transactionID: String.t(),
        index: String.t(),
        amount: integer
    }

    defstruct [ :transactionID, :index, :amount]

    def createCBUTXO(transactionID,index,amount) do
        %UTXO{
            transactionID: transactionID,
            index: index,
            amount: amount
        }
    end

    def calculateBalance(myUTXOList) do
        balance=if(length(myUTXOList)==0) do
            0
        else 
            totalUTXO=for i <- 1..length(myUTXOList) do
                myUTXO=Enum.at(myUTXOList,i-1)
                myUTXO.amount
            end
            balance=Enum.reduce(totalUTXO, fn x, acc -> x + acc end)
            balance
        end
        balance
    end

    def selectUTXO(myUTXOList,totalAmount) do
        if(Enum.empty?(myUTXOList)==true) do
            [[],[]]
        else
            newUTXOList=Enum.sort_by(myUTXOList, &(&1.amount)) |> Enum.reverse()
            myAmountList=for i <- 1..length(newUTXOList) do
                Enum.at(newUTXOList,i-1).amount
            end
            amountPrefixList=Enum.scan(myAmountList, &(&1 + &2))
            myAnswer=nextBigger(amountPrefixList,totalAmount)
            #IO.inspect(myAnswer)
            selectedUTXOList=cond do
                myAnswer==-1 ->
                    []
                true ->
                    Enum.slice(newUTXOList,0..myAnswer)
            end
            removedUTXOList=newUTXOList--selectedUTXOList
            [selectedUTXOList,removedUTXOList]
        end
    end

    def nextBigger(list, target) do
        cond do
            target>(Enum.at(list,-1)) ->
                -1
            target<(Enum.at(list,0)) ->
                0
            true ->
                nextBigger(list, target, 0, length(list) - 1)
        end
      end
    
      def nextBigger(list, _target, low, high) when low === high do
        low
      end
    
      def nextBigger(list, target, low, high) do
        mid = trunc(div(low + high, 2))
        if((Enum.at(list,mid))<target) do
            nextBigger(list, target, mid + 1, high)
        else
            nextBigger(list,target,low,mid)
        end
    end

end