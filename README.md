# Ethereum Private Network with Kurtosis

[![Tests](https://github.com/gustavovalverde/eth-private-network/actions/workflows/tests-k8s-run.yaml/badge.svg)](https://github.com/gustavovalverde/eth-private-network/actions/workflows/tests-k8s-run.yaml)

This repository contains the necessary files to deploy a private Ethereum network using [Kurtosis](https://www.kurtosis.com/) with the [Ethereum Package](https://github.com/ethpandaops/ethereum-package).

## TLDR to test this

### Prerequisites

- [Kurtosis CLI](https://docs.kurtosis.com/install/)
- [Docker](https://docs.docker.com/install/)
- [Minikube](https://kubernetes.io/docs/setup/) (optional)

With Docker and Kurtosis CLI installed, you can run the following command to deploy the network:

```shell
kurtosis run --enclave private-testnet --args-file network_params.yaml .
```

If you want to run the network in a local Kubernetes cluster, that's outside the scope of the TLDR, but you can find the instructions in the [Minikube section](#minikube).

## Reasoning behind this tool selection

As this repository is scoped to deploy a private Ethereum network, the tools selected were chosen to make the deployment as easy as possible. Kurtosis is a tool that allows you to deploy a network of services in a containerized environment, and it provides a simple way to define the network parameters and the services that will be deployed, allowing to integrate existing logging, monitoring, and testing tools used in the Ethereum ecosystem, while keeping an ample amount of flexibility that allows to use different combinations of Execution Layers (ELs) with Consensus Layers (CLs), using custom images, alternate validators, and different networks, like Goerli, Sepolia, Holesky, and others.

Additionally, the Ethereum Package being extended here is supported by [multiple DevOps](https://ethpandaops.io/team/) that are part of Ethereum, the Ethereum Foundation, and other organizations, giving a sense of trust and reliability to the package.

### Why not use Docker Compose?

While Docker Compose is a great tool to deploy a network of services, it lacks some features that Kurtosis provides, such as the ability to define an API to modify the network, services and the ability to run tests on the network, giving the ability to create a package that can be shared with others—just as the Ethereum Package was built and it's being extended here—.

### Why not use Helm?

When talking about packages the next tool that comes to mind is Helm—the package manager for Kubernetes—, but Helm is more focused on deploying applications in a Kubernetes cluster, and you might not be familiar with Kubernetes, and you might not want to learn it just to deploy a private Ethereum network for testing purposes.

> [!NOTE]
> If you are looking to deploy a private Ethereum network in a production environment (or public Dev/Testnet networks), you should consider using Helm or other tools that are more focused for this purpose. Consider using https://github.com/ethpandaops/template-devnets or https://github.com/ethpandaops/ethereum-helm-charts

### Caveats

Kurtosis is a tool that is still in development, and it might have some rough edges, but it's a great tool to deploy a network of services in a containerized environment, and it provides a simple way to define the network parameters and the services that will be deployed when paired with the [Ethereum Package](https://github.com/ethpandaops/ethereum-package).

Unfortunately, Kurtosis doesn't have a way to easily migrate or deploy using other tools, such as Helm, Argo CD, or others, causing friction when trying to transition from a development environment to a production environment.

> [!WARNING]
> Right now, Kurtosis is best suited for loca/dev/testing use cases and simplifying onboarding to a distributed app. It's missing some features fto use it as a production deployment or infrastructure management tool.

## Understanding Kurtosis and the Ethereum Package

The best places to start are:

- [Setting up a local Ethereum testnet with Kurtosis](https://docs.kurtosis.com/how-to-local-eth-testnet)
- The Ethereum Package [Architecture](https://github.com/ethpandaops/ethereum-package/blob/main/docs/architecture.md)
- The Ethereum Package [Usage](https://ethpandaops.io/posts/kurtosis-deep-dive/)

### Advanced topics

- [Running an L2 devnet](https://ethpandaops.io/posts/kurtosis-l2/) on top of the Ethereum Package
- [Testing](https://ethpandaops.io/posts/assertoor-introduction/) with the Ethereum Package

## What to expect from this package

This package is mainly governed by the configurations in the `network_params.yaml` file, which is a YAML file that contains the parameters used to deploy the network, including:

- Execution Layer (EL) and Consensus Layer (CL) configurations
- Number of nodes
- Node configurations
- Network configurations
- Service configurations
- Test configurations
- And more

The `network_params.yaml` file is the main file that you should look at to understand how the network is configured and what services are being deployed. You can extend this file to add more services, change the network configurations, or add more nodes to the network.

### Included services

#### Nodes Monitoring

- [Prometheus](https://prometheus.io/)
- [Grafana](https://grafana.com/)
- [beacon-metrics-gazer](https://crates.io/crates/beacon-metrics-gazer)
- [Node Monitor](https://github.com/ethereum/nodemonitor) (`el_fokmon`)

#### Explorers & Scanning

- [Dora](https://github.com/ethpandaops/dora)
- [Tracoor](https://ethpandaops.io/posts/tracoor-debug-tool/)
- [Blobscan](https://blobscan.com/)

#### Testing

- [Assertoor](https://ethpandaops.io/posts/assertoor-introduction/)

### Services configuration and customization

The default services configuration can be find in the upstream [Ethereum Package](https://github.com/ethpandaops/ethereum-package/tree/main/static_files) repository. Further customization can be done by extending the `main.star` file, which is a [Starlark](https://bazel.build/rules/language) file that allows you to define the services that will be deployed in the network.

## Minikube

If you want to run the network in a local Kubernetes cluster, you can use Minikube. To do so, you need to have Minikube installed and running, to do so, you can follow this instructions:

- [Install Minikube](https://github.com/kubernetes/minikube)
- Run `minikube start`
- Copy these contents to `kurtosis-config.yaml` file in `"$(kurtosis config path)"`:

```yaml
config-version: 2
should-send-metrics: true
kurtosis-clusters:
  docker:
    type: "docker"
  minikube:
    type: "kubernetes"
    config:
      kubernetes-cluster-name: "minikube"
      storage-class: "standard"
      enclave-size-in-megabytes: 10
```

- Run `kurtosis cluster set minikube`
- In another terminal, run `kurtosis gateway`. This will act as a middle man between your computer's ports and your services deployed on Kubernetes ports and has to stay running as a separate process. More info: https://docs.kurtosis.com/k8s/#iv-configure-kurtosis
- Run `kurtosis engine restart --enclave-pool-size 3` (this step is optional, but it's recommended taking it as it improves the user experience during the enclave creation, specifically regarding speed)
- Run `kurtosis run --enclave private-testnet --args-file network_params.yaml .`

### Troubleshooting

If your minikube gets exhausted, you can run it with maximum resources available on your machine. This might be a bit overkill, but it's a good way to ensure that you have enough resources to run your Ethereum Network.

```shell
minikube start --memory=max --cpus=max
```

If you're having this error, it might be because your minikube is running out of resources:
  
```shell
ERRO[2024-09-30T19:57:16+01:00] An error occurred connecting to engine '35f9b86b4c674c95a30e075f3104f0e7':
Expected to be able to get a port forwarded connection to engine '35f9b86b4c674c95a30e075f3104f0e7', instead a non-nil error was returned
 --- at /root/project/cli/cli/kurtosis_gateway/live_engine_client_supplier/reconnecting_engine_client_supplier.go:160 (LiveEngineClientSupplier.replaceCurrentEngineInfo) ---
Caused by: Expected to be able to find an api endpoint for Kubernetes portforward to engine '35f9b86b4c674c95a30e075f3104f0e7', instead a non-nil error was returned
 --- at /root/project/cli/cli/kurtosis_gateway/connection/provider.go:69 (GatewayConnectionProvider.ForEngine) ---
Caused by: Expected to find exactly 1 running Kurtosis Engine pod, instead found '0'
 --- at /root/project/cli/cli/kurtosis_gateway/connection/provider.go:137 (GatewayConnectionProvider.getEnginePodPortforwardEndpoint) --- 
```
