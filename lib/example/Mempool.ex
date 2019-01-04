defmodule Example.Mempool do
    
    def selectTransactions(myMempoolList) do
        newMempoolList=Enum.sort_by(myMempoolList, &(&1.transactionFee)) |> Enum.reverse()
        transactionList=cond do
            length(newMempoolList)==0 ->
                []
            length(newMempoolList)==1 ->
                [Enum.at(newMempoolList,0)]
            length(newMempoolList)==2 ->
                [Enum.at(newMempoolList,0),Enum.at(newMempoolList,1)]
            length(newMempoolList)==3 ->
                [Enum.at(newMempoolList,0),Enum.at(newMempoolList,1),Enum.at(newMempoolList,2)]
            true ->
                [Enum.at(newMempoolList,0),Enum.at(newMempoolList,1),Enum.at(newMempoolList,2),Enum.at(newMempoolList,3)]
        end
        updatedMempoolList=newMempoolList--transactionList
        transactionIDList=cond do
            length(newMempoolList)==0 ->
                ["","","",""]
            length(newMempoolList)==1 ->
                myTX1=Enum.at(myMempoolList,0)
                tid1=myTX1.transactionID
                [tid1,"","",""]
            length(newMempoolList)==2 ->
                myTX1=Enum.at(myMempoolList,0)
                tid1=myTX1.transactionID
                myTX2=Enum.at(myMempoolList,1)
                tid2=myTX2.transactionID
                [tid1,tid2,"",""]
            length(newMempoolList)==3 ->
                myTX1=Enum.at(myMempoolList,0)
                tid1=myTX1.transactionID
                myTX2=Enum.at(myMempoolList,1)
                tid2=myTX2.transactionID
                myTX3=Enum.at(myMempoolList,2)
                tid3=myTX3.transactionID
                [tid1,tid2,tid3,""]
            true ->
                myTX1=Enum.at(myMempoolList,0)
                tid1=myTX1.transactionID
                myTX2=Enum.at(myMempoolList,1)
                tid2=myTX2.transactionID
                myTX3=Enum.at(myMempoolList,2)
                tid3=myTX3.transactionID
                myTX4=Enum.at(myMempoolList,3)
                tid4=myTX4.transactionID
                [tid1,tid2,tid3,tid4]
        end
        [transactionList,updatedMempoolList,transactionIDList]
    end
end