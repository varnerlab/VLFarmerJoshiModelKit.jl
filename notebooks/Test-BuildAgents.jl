### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ f63bf213-75fd-4722-bc7a-8cded43bc53a
begin
	using Parameters
end

# ╔═╡ 1c7e58cb-e4e9-49af-b782-b107e61196d7
# how many iterations?
number_of_iterations = 1000

# ╔═╡ a0bb564e-5c10-4d0e-8685-b4d5af6bbed2
# how many agents?
number_of_agents = 10

# ╔═╡ 624d2477-c19a-49c8-888d-23a580b63842
# how many assets?
number_of_assets = 10

# ╔═╡ bcebefc3-d63e-4340-a944-63fe273356b9
function ingredients(path::String; module_name::Symbol = :model)
	
	# this is from the Julia source code (evalfile in base/loading.jl)
	# but with the modification that it returns the module instead of the last object
	
	# JV change ... want to
	# name = Symbol(basename(path))
	name = module_name
	
	# original -
	m = Module(name)
	Core.eval(m,
        Expr(:toplevel,
             :(eval(x) = $(Expr(:core, :eval))($name, x)),
             :(include(x) = $(Expr(:top, :include))($name, x)),
             :(include(mapexpr::Function, x) = $(Expr(:top, :include))(mapexpr, $name, x)),
             :(include($path))))
	m
end

# ╔═╡ 31e84c23-0f9a-42f1-ab34-00def17db241
begin
	
	# load my code into module M -
	M = ingredients("../Include.jl"; module_name = :ABM)
	
	# alias my types that are declared -
	VLAgentModel = M.VLAgentModel
	VLGameWorld = M.VLGameWorld
	
	# return -
	nothing 
end

# ╔═╡ 8b63e2b6-25e1-40cf-beb6-dc74d930806e
# setup the game world -
game_world = M.build(VLGameWorld; number_of_iterations=number_of_iterations, number_of_assets=number_of_assets)

# ╔═╡ b57bc814-c397-450e-97c9-e3a0a84c03f7
# setup the agents -
begin
	
	my_agent_array = Array{VLAgentModel,1}()
	for agent_index = 1:number_of_agents
		
		# let's use the defaults for the various agent settings -
		agent_model = M.build(VLAgentModel; number_of_iterations=number_of_iterations, number_of_assets=number_of_assets)
	
		# grab -
		push!(my_agent_array, agent_model)
	end
	
	my_agent_array
end

# ╔═╡ 6c53c6b9-f870-4fce-8302-093c9ae74e0f
html"""
<style>
main {
    max-width: 1200px;
    margin: auto;
	width: 90%;
    font-family: "Roboto, monospace";
}

a {
    color: blue;
    text-decoration: none;
}

.H1 {
    padding: 0px 30px;
}
</style>
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Parameters = "d96e819e-fc66-5662-9728-84c9c7592b0a"

[compat]
Parameters = "~0.12.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"
"""

# ╔═╡ Cell order:
# ╠═f63bf213-75fd-4722-bc7a-8cded43bc53a
# ╠═31e84c23-0f9a-42f1-ab34-00def17db241
# ╠═1c7e58cb-e4e9-49af-b782-b107e61196d7
# ╠═a0bb564e-5c10-4d0e-8685-b4d5af6bbed2
# ╠═624d2477-c19a-49c8-888d-23a580b63842
# ╠═8b63e2b6-25e1-40cf-beb6-dc74d930806e
# ╠═b57bc814-c397-450e-97c9-e3a0a84c03f7
# ╟─bcebefc3-d63e-4340-a944-63fe273356b9
# ╟─6c53c6b9-f870-4fce-8302-093c9ae74e0f
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
