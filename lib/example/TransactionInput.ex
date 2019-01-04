defmodule Example.TInput do
    alias Example.{TInput}

    @type t :: %__MODULE__{
        previousTransactionID: String.t(),
        previousVOut: integer
    }

    defstruct [ :previousTransactionID, :previousVOut]

    def prepareTInput(numInputs,myTList,myVOut) do
        inputList=if(numInputs==0) do
            []
        else
            for i <- 1..numInputs do
                %TInput{
                    previousTransactionID: Enum.at(myTList,i-1),
                    previousVOut: Enum.at(myVOut,i-1)
                }
            end
        end
        inputList
    end
end