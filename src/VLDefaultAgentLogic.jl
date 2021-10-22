function _default_agent_update_logic(agent::VLAgentModel, order::VLOrderModel, price_array::Array{Float64,2}, iteration_index::Int64)

    try
        
        # get stuff from the order -
        order_quantity = order.quantity                   # what is the order quantity?
        order_action = order.action                       # what is the order action?
        asset_index = order.asset_index                   # what asset was associated with this order 
        
        # get stuff the agent -
        agent_position_array = agent.agent_position_array

        # update the position array -
        current_position = agent_position_array[iteration_index, asset_index]
        new_position = 0
        if (order_action == BUY)
            new_position = current_position + order_quantity
        elseif (order_action == SELL)
            new_position = current_position - order_quantity
        else
            new_position = current_position
        end
        agent_position_array[iteration_index, asset_index] = new_position

        # update -
        agent.agent_position_array = agent_position_array
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