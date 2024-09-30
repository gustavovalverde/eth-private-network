ethereum_package = import_module("github.com/ethpandaops/ethereum-package/main.star")
# wait_for_sync = import_module("./src/wait/wait_for_sync.star")

# TODO: Deploy a modified contract with fhEVM
# contract_deployer = import_module("./src/contracts/contract_deployer.star")

def run(plan, args):
    plan.print("Deploying a local Ethereum devnet")
    # Run the Ethereum devnet and store the context in a variable called l1
    l1 = ethereum_package.run(plan, args)
    plan.print(l1.network_params)
    # Get L1 info
    # Read the RPC URL of the first participant in the Ethereum devnet and store it in a variable called l1_rpc
    l1_rpc = l1.all_participants[0].el_context.rpc_http_url
    all_l1_participants = l1.all_participants
    l1_network_params = l1.network_params
    l1_network_id = l1.network_id
    l1_priv_key = l1.pre_funded_accounts[
        12
    ].private_key  # reserved for L2 contract deployers
    l1_config_env_vars = get_l1_config(
        all_l1_participants, l1_network_params, l1_network_id
    )

    # TODO: Deploy A fhEVM contract on L1
    # contract_deployer.deploy(plan, l1_priv_key, l1_config_env_vars)

def get_l1_config(all_l1_participants, l1_network_params, l1_network_id):
    env_vars = {}
    env_vars["L1_RPC_KIND"] = "any"
    env_vars["WEB3_RPC_URL"] = str(all_l1_participants[0].el_context.rpc_http_url)
    env_vars["L1_RPC_URL"] = str(all_l1_participants[0].el_context.rpc_http_url)
    env_vars["CL_RPC_URL"] = str(all_l1_participants[0].cl_context.beacon_http_url)
    env_vars["L1_WS_URL"] = str(all_l1_participants[0].el_context.ws_url)
    env_vars["L1_CHAIN_ID"] = str(l1_network_id)
    env_vars["L1_BLOCK_TIME"] = str(l1_network_params.seconds_per_slot)

    return env_vars
