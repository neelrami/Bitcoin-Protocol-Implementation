defmodule Example.Chain do
    alias Example.{Block,Wallet,MerkleTree,Transactions,UTXO,Mempool}

    use GenServer


    def init(myState) do
        processIndex=Enum.at(myState,0)
        blockchain=[Block.genesisBlock()]
        myWallet=Wallet.generateWallet()
        myUTXO=[]
        mempool=[]
        nList=Enum.at(myState,1)
        myState=[processIndex,blockchain,myWallet,myUTXO,mempool,nList]
        #IO.inspect(myState)
        {:ok,myState}    
    end

    def handle_call({:getRecentBlock}, _from, myState) do
        blockchain=Enum.at(myState,1)
        recentBlock=Enum.at(blockchain,-1)
        {:reply, recentBlock, myState}
    end

    def handle_call({:displayBlockChain}, _from, myState) do
        blockchain=Enum.at(myState,1)
        {:reply, blockchain, myState}
    end

    def handle_call({:mining}, _from, myState) do
        aList=Mempool.selectTransactions(Enum.at(myState,4))
        #IO.inspect(aList)
        blockchain=Enum.at(myState,1)
        recentBlock=Enum.at(blockchain,-1)
        nextIndex=recentBlock.blockHeight+1
        previousBlockHash=recentBlock.currentBlockHash
        transactions=Enum.at(aList,0)
        transactionsID=Enum.at(aList,2)
        merkleRoot=Base.encode16(MerkleTree.new(transactionsID).root.value)
        timestamp=System.system_time(:seconds)
        
        blockHeaderString=Block.createString(nextIndex,previousBlockHash,merkleRoot,timestamp)
        
        {blockHeaderHash,nonce}=Block.proofOfWork(blockHeaderString,0)
        
        newBlock=Block.generateBlock(nextIndex,previousBlockHash,merkleRoot,timestamp,blockHeaderHash,transactions,nonce)
        myNewState=[Enum.at(myState,0),Enum.at(myState,1),Enum.at(myState,2),Enum.at(myState,3),Enum.at(aList,1),Enum.at(myState,5)]
        {:reply,[Enum.at(myState,0),newBlock],myNewState}      
    end

    def handle_call({:validateBlock, currentBlock}, _from, myState) do
        latestBlock=Block.getLatestBlock(myState)
        var1=latestBlock.currentBlockHash==currentBlock.previousBlockHash
        var2=(latestBlock.blockHeight+1)==currentBlock.blockHeight
        var3=Block.verifyProofOfWork(currentBlock)
        var4=Block.verifyHash(currentBlock)
        if((var1 and var2 and var3 and var4)==true) do
            {:reply, "Valid Block" , myState}
        else
            {:reply, "Invalid Block", myState}
        end
    end

    def handle_call({:replaceChain, currentBlock}, _from, myState) do
        oldBlockChain=Enum.at(myState,1)
        newBlockChain=oldBlockChain ++ [currentBlock]
        myNewState=[Enum.at(myState,0),newBlockChain,Enum.at(myState,2),Enum.at(myState,3),Enum.at(myState,4),Enum.at(myState,5)]
        {:reply, "Replaced", myNewState}
    end

    def handle_call({:getCBT}, _from, myState) do
        {:reply, Transactions.coinbaseTransaction(myState), myState}
    end

    def handle_call({:getPA}, _from, myState) do
        myPA=Enum.at(myState,2).publicAddress
        {:reply, myPA, myState}    
    end

    def handle_call({:addUTXO, myUTXO},_from,myState) do
        myNewUTXO=%UTXO{
            transactionID: Enum.at(myUTXO,0),
            index: Enum.at(myUTXO,1),
            amount: Enum.at(myUTXO,2)
        }
        myUTXOList=Enum.at(myState,3)++[myNewUTXO]
        myNewState=[Enum.at(myState,0),Enum.at(myState,1),Enum.at(myState,2),myUTXOList,Enum.at(myState,4),Enum.at(myState,5)]
        {:reply, myNewState, myNewState}
    end

    def handle_call({:getBalance},_from,myState) do
        myBalance=UTXO.calculateBalance(Enum.at(myState,3))
        {:reply,myBalance,myState}
    end

    def handle_call({:displayState}, _from, myState) do
        {:reply, myState, myState}
    end

    def handle_call({:sendBitcoin,myInput}, _from, myState) do
        myList=Wallet.send(myState, Enum.at(myInput,0),Enum.at(myInput,1),Enum.at(myInput,2))
        transactionStatus=Enum.at(myList,0)
        if(transactionStatus=="notEnoughBalance") do
            {:reply,[Enum.at(myList,0),Enum.at(myList,1)],myState}
        else
            myNewState=Enum.at(myList,2)
            {:reply,[Enum.at(myList,0),Enum.at(myList,1)],myNewState}
        end
    end

    def handle_call({:addToMempool, myTX}, _from, myState) do
        newMempool=Enum.at(myState,4)++[myTX]
        myNewState=[Enum.at(myState,0),Enum.at(myState,1),Enum.at(myState,2),Enum.at(myState,3),newMempool,Enum.at(myState,5)]
        {:reply,Enum.at(myNewState,4),myNewState}
    end
end