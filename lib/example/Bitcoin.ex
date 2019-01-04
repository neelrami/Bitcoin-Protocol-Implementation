defmodule Example.Main do
    alias Example.{Chain,UTXO}
    
    def main(args \\ []) do
        args
        |> parse_args
        |> processInput
      end
    
    defp parse_args(args) do
        {_, myArg, _} =
          OptionParser.parse(args,strict: [:string])
          myArg
    end
    
    defp processInput(myArg) do
        if(length(myArg)!==1 ) do
          IO.puts("Please provide the command line arguments as follows: numNodes.")
          System.halt(0)
        else
          numNodes=String.to_integer(Enum.at(myArg,0))
          cond do
            numNodes==0 ->
              IO.puts("Number of Nodes should be greater than 0.")
              System.halt(0)
            true ->
              startBitcoin(numNodes)
          end
        end
    end

    def startBitcoin(numNodes) do
        Process.register(self(), :main)
        Registry.start_link(keys: :unique, name: PIDStore)
        
        
        nodeList=createNodeList(numNodes)
        nList=for i <- 1..numNodes do
            neighbourList=generateNeighbour(numNodes,i)
        end
        
        startNodes(numNodes,nodeList,nList)
        recentBlock=GenServer.call(whereis(Enum.at(nodeList,0)),{:getRecentBlock},:infinity)

        GenServer.call(whereis(Enum.at(nodeList,0)),{:addUTXO,["initialFee",0,25]},:infinity)
        recentBlock
        
    end

    def startNodes(numNodes,nodeList,nList) do
        Enum.map(1..numNodes, fn i -> startLink1(i,nodeList,nList) end)
    end

    def startLink1(nodeIndex,nodeList,nList) do
        {:ok,_pid}=GenServer.start_link(Chain, [nodeIndex,Enum.at(nList,nodeIndex-1)], name: via_tuple(Enum.at(nodeList,nodeIndex-1)))
    end

    def generateNeighbour(numNodes,nodeIndex) do
        tList = Enum.reject(1..numNodes, fn x -> x == nodeIndex end)
        Enum.take_random(tList, 5)
    end      

    def startMining(nodeList) do
        newList=Enum.shuffle(nodeList)
        currentBlockList=for i <- 1..length(newList) do
            newBlock=GenServer.call(whereis(Enum.at(newList,i-1)),{:mining},:infinity)
            newBlock
        end
        currentBlockList
    end

    def validateBlock(nList,newCandidateBlock) do
        for i <- 1..length(nList) do
            myNeighbour=Enum.at(nList,i-1)
            mybc=GenServer.call(whereis(Enum.at(nList,myNeighbour-1)),{:validateBlock, newCandidateBlock},:infinity)
            #IO.inspect(mybc)
        end
    end

    def getPublicAddresses(nodeList) do
        myPublicAddressList=for i <- 1..length(nodeList) do
            myPA=publicAddress=GenServer.call(whereis(Enum.at(nodeList,i-1)),{:getPA},:infinity)
        end 
        myPublicAddressList   
    end

    def miningProcedure(numNodes) do
        nodeList=createNodeList(numNodes)
        myPAList=getPublicAddresses(nodeList)
        IO.inspect("STEP 1: Mining Started.")
        
        currentBlockList=startMining(nodeList)
        
        iList=for i <- 1..length(currentBlockList) do
            Enum.at(Enum.at(currentBlockList,i-1),0)    
        end

        #IO.inspect(iList)

        newCandidateBlock=Enum.at(Enum.at(currentBlockList,0),1)
        miningProcess=Enum.at(Enum.at(currentBlockList,0),0)
        
        IO.inspect("STEP 2: Process " <> Integer.to_string(miningProcess) <> " found a new block.")
        
        validateBlock(nodeList,newCandidateBlock)

        IO.inspect("STEP 3: Block Validation")

        myList1=GenServer.call(whereis(Enum.at(nodeList,miningProcess-1)),{:getCBT}, :infinity)
        
        IO.inspect("STEP 4: Coinbase Transaction added to Block")

        newCandidateBlock1=%{newCandidateBlock | miningProcess: Enum.at(iList,0), transactions: [Enum.at(myList1,0)], transactionCounter: 1}

        #IO.inspect(newCandidateBlock1)
        
        for i <- 1..length(newCandidateBlock1.transactions) do
            myTX=Enum.at(newCandidateBlock1.transactions,i-1)
            myReceiverList=for j <- 1..length(myTX.outputs) do
                myOutput=Enum.at(myTX.outputs,j-1)
                myOutput.receiver
            end
            myAmountList=for j <- 1..length(myTX.outputs) do
                myOutput=Enum.at(myTX.outputs,j-1)
                myOutput.amount
            end

            for j <- 1..length(myReceiverList) do
                myPA=Enum.at(myReceiverList,j-1)
                myUTXO=[myTX.transactionID,j-1,Enum.at(myAmountList,j-1)]
                #IO.inspect(Enum.find_index(myPAList, fn x -> x==myPA end))
                aaa=GenServer.call(whereis(Enum.find_index(myPAList, fn x -> x==myPA end)+1),{:addUTXO,myUTXO}, :infinity)
                #IO.inspect(aaa)
            end
            myReceiverList=Enum.reject(myReceiverList, fn x -> x !="" end)
            myAmountList=Enum.reject(myAmountList, fn x -> rem(x,1)==0 end)
        end
        IO.inspect("STEP 5: UTXO Added")

        for i <- 1..length(nodeList) do
            mybc=GenServer.call(whereis(Enum.at(nodeList,i-1)),{:replaceChain, newCandidateBlock1},:infinity)
            #IO.inspect(mybc)
        end
        IO.inspect("STEP 6: Block Added to BlockChain")

        newBlockChain=GenServer.call(whereis(Enum.at(nodeList,miningProcess-1)),{:displayBlockChain},:infinity)
        #IO.inspect(newBlockChain)

        IO.inspect("STEP 7: Calculating Balance of 2 Processes")
        for i <- 1..length(nodeList) do
            myBalance=GenServer.call(whereis(Enum.at(nodeList,i-1)),{:getBalance},:infinity)
            IO.inspect("Balance of Process " <> Integer.to_string(i) <> " is " <> Integer.to_string(myBalance))
        end

        recentBlock=GenServer.call(whereis(Enum.at(nodeList,0)),{:getRecentBlock},:infinity)
        #IO.inspect(Poison.encode(recentBlock))
        recentBlock
    end


    def via_tuple(nodeIdentifier), do: {:via, Registry, {PIDStore, nodeIdentifier}}
  
    def whereis(nodeIdentifier) do
        case Registry.lookup(PIDStore, nodeIdentifier) do
            [{pid, _}] -> pid
            [] -> nil
        end
    end

    def createNodeList(numNodes) do
        Enum.to_list(1..numNodes)
    end

    def startTransaction(senderProcess,receiverProcess,amount,fee) do
        nodeList=createNodeList(100)
        myPAList=getPublicAddresses(nodeList)

        sendAmount=amount
        transactionFee=fee

        #IO.inspect("Process 1 sends 20 BTC to Process 2")
        myTXList=GenServer.call(whereis(Enum.at(nodeList,senderProcess-1)),{:sendBitcoin,[[Enum.at(myPAList,receiverProcess-1)],[sendAmount],fee]},:infinity)
        
        tStatus=Enum.at(myTXList,0)
        myTX=Enum.at(myTXList,1)

        if(tStatus=="notEnoughBalance") do
            bbb=[-1,-1,-1,[],tStatus]
            bbb
        else
            miningProcessList=for i <- 1..100 do
                if(i !=senderProcess and i !=receiverProcess) do
                    i
                end
            end

            finalMList=Enum.reject(miningProcessList, &is_nil/1)

            myNewList=Enum.shuffle(finalMList)        
            aProcess=Enum.at(myNewList,0)

            myUTXO=["TFee",0,transactionFee]
            GenServer.call(whereis(Enum.at(nodeList,aProcess-1)),{:addUTXO,myUTXO},:infinity)
            IO.inspect("Transaction Created and added to Mempool")
            _myMempool=GenServer.call(whereis(Enum.at(nodeList,aProcess-1)),{:addToMempool,myTX},:infinity)
        

            newBlock=GenServer.call(whereis(Enum.at(nodeList,aProcess-1)),{:mining},:infinity)
            IO.inspect("Transaction has been mined")
        
            miningProcess1=Enum.at(newBlock,0)
        

            myList1=GenServer.call(whereis(Enum.at(nodeList,miningProcess1-1)),{:getCBT}, :infinity)
        
            myNewBlock=Enum.at(newBlock,1)
            myTransactions=myNewBlock.transactions++[Enum.at(myList1,0)]
            newBlock1=%{myNewBlock | miningProcess: aProcess, transactions: myTransactions}
            
            for i <- 1..length(newBlock1.transactions) do
                myTX=Enum.at(newBlock1.transactions,i-1)
                myReceiverList=for j <- 1..length(myTX.outputs) do
                    myOutput=Enum.at(myTX.outputs,j-1)
                    myOutput.receiver
                end
                myAmountList=for j <- 1..length(myTX.outputs) do
                    myOutput=Enum.at(myTX.outputs,j-1)
                    myOutput.amount
                end
        
                for j <- 1..length(myReceiverList) do
                    myPA=Enum.at(myReceiverList,j-1)
                    #IO.inspect(myPA)
                    myUTXO=[myTX.transactionID,j-1,Enum.at(myAmountList,j-1)]
                    #IO.inspect(Enum.find_index(myPAList, fn x -> x==myPA end))
                    #IO.inspect(GenServer.call(whereis(Enum.find_index(myPAList, fn x -> x==myPA end)+1),{:addUTXO,myUTXO}, :infinity))
                    aaa=GenServer.call(whereis(Enum.find_index(myPAList, fn x -> x==myPA end)+1),{:addUTXO,myUTXO}, :infinity)
                    #IO.inspect(aaa)
                end
                myReceiverList=Enum.reject(myReceiverList, fn x -> x !="" end)
                myAmountList=Enum.reject(myAmountList, fn x -> rem(x,1)==0 end)
            end
            #IO.inspect("UTXO Added")

            for i <- 1..length(nodeList) do
                _mybc=GenServer.call(whereis(Enum.at(nodeList,i-1)),{:replaceChain, newBlock1},:infinity)
                #IO.inspect(mybc)
            end
            #IO.inspect("Chain Replaced")


            mybc=GenServer.call(whereis(Enum.at(nodeList,miningProcess1-1)),{:displayBlockChain},:infinity)
            IO.inspect(mybc)
        
            myBalanceList=for i <- 1..length(nodeList) do
                myBalance=GenServer.call(whereis(Enum.at(nodeList,i-1)),{:getBalance},:infinity)
                IO.inspect("Balance of Process " <> Integer.to_string(i) <> " is " <> Integer.to_string(myBalance))
                myBalance
            end

            aaa=[senderProcess,receiverProcess,amount,newBlock1,tStatus]
            aaa
        end
    end

end