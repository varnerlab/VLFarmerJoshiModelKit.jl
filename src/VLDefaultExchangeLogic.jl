function _default_exchange_logic(iteration_index, game_world::VLGameWorld, 
    order_array::Array{VLOrderModel}, current_asset_price_array::Array{Float64,2})::Array{Float64,2}

    try

        # initialize -
        agent_array = game_world.agent_array
        number_of_assets = game_world.number_of_assets
        λ = game_world.liquidity_parameter_array
        number_of_orders = length(order_array)
        order_book = Array{Int64,2}(undef, number_of_assets, number_of_orders)

        # build agent table -
        agent_table = Dict{UUID,VLAbstractAgentModel}()
        for agent in agent_array
            agent_id = agent.agent_id
            agent_table[agent_id] = agent
        end

        # let process the orders - first, build the order book 
        for order_index = 1:number_of_orders
            
            # grab the order -
            order_model = order_array[order_index]
            asset_index = order_model.asset_index   # what asset index is this order?
            order_quantity = order_model.quantity   # what is the order quantity?
            order_action = order_model.action       # what is the oder action?

            # add order to the order book for this asset -
            if (order_action == BUY)
                order_book[asset_index, order_index] = order_quantity
            elseif (order_action == SELL)
                order_book[asset_index, order_index] = -1 * order_quantity
            else
                order_book[asset_index, order_index] = 0
            end
        end

        # generate total order for each asset -
        total_order_quantity = sum(order_book, dims=2)

        # update the price for each asset -
        new_asset_price_array = similar(current_asset_price_array)
        for asset_index = 1:number_of_assets
            current_price = current_asset_price_array[iteration_index, asset_index]
            new_asset_price_array[iteration_index, asset_index] = current_price + (1 / λ[asset_index]) * total_order_quantity[asset_index]
        end

        

        # return -
        return new_asset_price_array
    catch error
        throw(error)
    end
end