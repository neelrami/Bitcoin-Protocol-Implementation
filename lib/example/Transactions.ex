defmodule Example.Transactions do
    
    alias Example.{Transactions,TInput,TOutput,Wallet,WalletFunctions,UTXO}

    @type t :: %__MODULE__{
        transactionID: String.t(),
        type: String.t(),
        numInputs: integer,
        numOutputs: integer,
        inputs: [TInput.t()],
        outputs: [TOutput.t()],
        signature: String.t(),
        transactionFee: integer,
        timestamp: integer
    }

    defstruct [ :transactionID, :type, :numInputs, :numOutputs, :inputs, :outputs, :signature, :transactionFee, :timestamp]

    def coinbaseTransaction(myState) do
        myTX=%Transactions{
            type: "coinbase", 
            numInputs: 0,
            numOutputs: 1,
            inputs: [],
            outputs: TOutput.prepareTOutput(1,[Enum.at(myState,2).publicAddress],[25]),
            transactionFee: 0,
            timestamp: System.system_time(:seconds)
        }
        signString=createSigningString(myTX,myState)
        signature=Wallet.sign(myState,signString)
        myTX1 = %{myTX | signature: signature}
        myCBT=%{myTX1 | transactionID: calTransactionID(myTX1,myState)}
        myUTXO=UTXO.createCBUTXO(myTX1.transactionID,0,25)
        [myCBT,myUTXO]
    end

    def createTransaction(myState,numInputs,numOutputs,prevTransactionList,voutIndex, receiverList, amountList, transactionFee) do
        myTX=%Transactions{
            type: "normal",
            numInputs: numInputs,
            numOutputs: numOutputs,
            inputs: TInput.prepareTInput(numInputs,prevTransactionList,voutIndex),
            outputs: TOutput.prepareTOutput(numOutputs,receiverList,amountList),
            transactionFee: transactionFee,
            timestamp: System.system_time(:seconds)
        }
        signString=createSigningString(myTX,myState)
        #IO.inspect(signString)
        signature=Wallet.sign(myState,signString)
        myTX1 = %{myTX | signature: signature}
        %{myTX1 | transactionID: calTransactionID(myTX1,myState)}

    end

    def createSigningString(%Transactions{}=myTX,myState) do
        myString=if(length(myTX.inputs)==0) do
            Enum.at(myTX.outputs,0).receiver<>Integer.to_string(Enum.at(myTX.outputs,0).amount)
        else
            inputList=for i <- 1..length(myTX.inputs) do
                myTXInput=Enum.at(myTX.inputs,i-1)
                [myTXInput.previousTransactionID,myTXInput.previousVOut]
            end
            inputList1=List.flatten(inputList)
            outputList=for i <- 1..length(myTX.outputs) do
                myTXOutput=Enum.at(myTX.outputs,i-1)
                [myTXOutput.receiver,myTXOutput.amount]
            end
            outputList1=List.flatten(outputList)
            myList=inputList1++outputList1
            myList1=for i <- 1..length(myList) do
                if(rem(i,2)==1) do
                    Enum.at(myList,i-1)
                else
                    Integer.to_string(Enum.at(myList,i-1))
                end
            end
            Enum.reduce(myList1,"", fn x, acc -> acc<>x end)
        end
        myString<>Enum.at(myState,2).publicKey
    end

    def calTransactionID(%Transactions{}=myTX,myState) do
        myString=createSigningString(myTX,myState)<>myTX.signature
        :crypto.hash(:sha256,myString) |> WalletFunctions.hashFunction(:sha256) |> Base.encode16(case: :lower)
    end
end