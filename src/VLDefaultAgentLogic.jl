function _default_agent_update_logic!(agent::VLAgentModel, order::VLOrderModel, price_array::Array{Float64,2}, iteration_index::Int64)

    try
        
        # get stuff from the order -
        order_quantity = order.quantity                   # what is the order quantity?
        order_action = order.action                       # what is the order action?
        asset_index = order.asset_index                   # what asset was associated with this order 
        
        # get stuff the agent -
        new_agent_position_array = copy(agent.agent_position_array)

        # update the position array -
        current_position = agent.agent_position_array[iteration_index - 1, asset_index]
        𝒪 = 0
        if (order_action == 1)
            𝒪 = current_position + order_quantity
        elseif (order_action == -1)
            𝒪 = current_position + order_quantity
        else
            𝒪 = current_position
        end

        if (𝒪 >= 0)
            new_agent_position_array[iteration_index, asset_index] = 𝒪
        end

        # update -
        agent.agent_position_array = new_agent_position_array

    catch error
        throw(error)
    end
end

function _default_agent_trade_logic()
    
    try

    catch error
        throw(error)
    end
end