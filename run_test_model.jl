include("Include.jl")

# setup trade logic -
function my_technical_agent_trade_logic(agent_model, asset_price_array, iteration_index)
	
	# initialize -
	order_model_array = Array{VLOrderModel,1}()
	agent_position_array = agent_model.agent_position_array
	
	# get the parameters from this agent -
	parameters_dict = agent_model.agent_parameters
	
	# get the c-parameter array -
	c_parameter_array = parameters_dict["c_parameter_array"]
	price_lag_array = parameters_dict["price_lag_array"]
	
	# compute the setpoint array -
	(number_of_iterations, number_of_assets) = size(asset_price_array)
	for asset_index = 1:number_of_assets
		
		# what is the lag?
		asset_lag_index = price_lag_array[asset_index]
	
		# what is the lagged price for this asset?
		price_setpoint_value = 1.0
		if (asset_lag_index < iteration_index)
			price_setpoint_value = asset_price_array[(iteration_index - asset_lag_index),asset_index]
		end
		
		# build the order model -
		c_value = c_parameter_array[asset_index]
		current_price = asset_price_array[asset_index]
		desired_position_size = c_value * sign(current_price - price_setpoint_value)
		Δω = agent_position_array[iteration_index, asset_index] - desired_position_size
		
		# build the order -
		# an order has this data -
		local_asset_index = asset_index
    	action = (Δω < 0) ? -1 : 1
    	order_type = 1
    	# quantity = abs(Δω)
        quantity = 2
    	price = current_price
    	agent_id = agent_model.agent_id
		order_model = VLOrderModel(local_asset_index, action, order_type, quantity, price, agent_id);	
		push!(order_model_array, order_model)
	end
	
	# return -
	return order_model_array
end

# build the game world -
number_of_iterations = 20
number_of_agents = 1
number_of_assets = 2
game_world = build(VLGameWorld; number_of_iterations=number_of_iterations, number_of_assets=number_of_assets);

# build agent array -
my_agent_array = Array{VLAgentModel,1}()
for agent_index = 1:number_of_agents
    
    # let's use the defaults for the various agent settings -
    agent_model = build(VLAgentModel; number_of_iterations=number_of_iterations, number_of_assets=number_of_assets)
    
    # setup parameters for this agent -
    c_array = rand(1:number_of_assets, number_of_assets)
    lag_array = rand(1:1, number_of_assets)
    p = Dict("c_parameter_array" => c_array, "price_lag_array" => lag_array)
    agent_model.agent_parameters = p
    
    # let's have all my agents be technical traders -
    agent_model.agent_trade_logic = my_technical_agent_trade_logic
        
    # grab -
    push!(my_agent_array, agent_model)
end

# attach the agents to the world -
game_world.agent_array = my_agent_array

# run the model -
R = run(game_world)