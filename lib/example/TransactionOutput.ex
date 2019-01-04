defmodule Example.TOutput do
    alias Example.{TOutput}

    @type t :: %__MODULE__{
        receiver: String.t(),
        amount: integer
    }

    defstruct [ :receiver, :amount]

    def prepareTOutput(numOutputs,receiverList,amountList) do
        outputList=for i <- 1..numOutputs do
            %TOutput{
                receiver: Enum.at(receiverList,i-1),
                amount: Enum.at(amountList,i-1)
            }
        end
        outputList
    end

end