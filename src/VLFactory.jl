function build(type::Type{VLAgentModel}; kwargs...)

    try

        # get the args as a dictionary -
        args = Dict(kwargs)
        trade_logic = args[:trade_logic]
        update_logic = args[:update_logic]
        wealth = args[:wealth]
        number_of_iterations = args[:number_of_iterations]
        number_of_assets = args[:number_of_assets]
        initial_position_array = args[:initial_position_array]

        # build a blank agent -
        agent_model = VLAgentModel()
        agent_model.agent_trade_logic = trade_logic
        agent_model.agent_update_logic = update_logic
        agent_model.agent_id = uuid4()
        
        # what is the agents initial wealth -
        wealth_array = Array{Float64,1}()
        push!(wealth_array, wealth)
        agent_model.agent_wealth_array = wealth_array

        # initialize the initial position array -
        agent_position_array = zeros(number_of_iterations, number_of_assets)
        for asset_index = 1:number_of_assets
            agent_position_array[1,asset_index] = initial_position_array[asset_index]
        end
        agent_model.agent_position_array = agent_position_array

        # return -
        return agent_model
    catch error
        rethrow(error)
    end
end

function build(type::Type{VLGameWorld}; kwargs...)

    try

        # get the args as a dictionary -
        args = Dict(kwargs)
        number_of_iterations = args[:number_of_iterations]
        number_of_assets = args[:number_of_assets]
        exchange_logic = args[:exchange_logic]
        
        # Create a blank game world -
        game_world = VLGameWorld()
        game_world.number_of_iterations = number_of_iterations
        game_world.exchange_logic = exchange_logic
        game_world.asset_price_array = zeros(number_of_iterations, number_of_assets)

        # return -
        return game_world
    catch error
        rethrow(error)
    end
end