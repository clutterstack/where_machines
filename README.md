# WhereMachines

This repo is public for purposes of curiosity. It's not intended to be deployed as-is.

WhereMachines is a Phoenix LiveView application that provides a button to launch small virtual machines of no practical use on the cloud compute platform [Fly.io](https://fly.io). Its companion project is [UselessMachine](https://github.com/clutterstack/useless_machine), a Phoenix LiveView application of no practical use that's easily launched in a virtual machine on Fly.io.

## Why?

I had some cool toys: Elixir and Phoenix/LiveView, and a bunch of Fly.io features. I was inspired by [Where Durable Objects Live](https://where.durableobjects.live/) which spawns a new Cloudflare Durable Object and reports where it ended up, which is also a perfect fit for Fly Machines. It seems a shame to spawn a VM for someone without letting them interact with it in some way, so I was soon preoccupied with the idea of finding a gratifying useless workload for the ephemeral Machines. This workload can be found at https://github.com/clutterstack/useless_machine.

## The basic idea

The landing-page app is [where_machines](https://github.com/clutterstack/where_machines). When deployed on Fly.io, it tells the visitor which Fly.io edge region their request reached the app through. It shows a world map with markers at the approximate locations of data centres that Fly.io runs user workloads on. If there are any instances of the Useless Machine app currently running, their worker locations are highlighted with a yellow dot.

There's a single button on the page. Clicking that button sends an API request to create a brand-new Fly Machine in the same region as the visitor's Fly.io edge server, and starts a timer as a visual aid. When the new Machine signals that it's ready, the visitor is redirected to its public URL.

The Useless Machine shows some content to the visitor that created it, then shuts itself down, whereupon it's destroyed.

## Implementation

* session affinity with fly-replay (using [Peter Ullrich's method](https://peterullrich.com/request-routing-and-sticky-sessions-in-phoenix-on-fly))
* local readiness checks on the Useless Machine
* private API endpoints with IPv6 private networking (WireGuard)
* Erlang clustering over 6PN (with DNSCluster) and PubSub for passing messages to components about the status of Useless Machine VMs
* a [Req-based API client for Fly Machines](https://github.com/clutterstack/clutterfly), to launch new Machines and query the API for current Machine status
* launching the Machine with a set of parameters, including a ref for a Docker image for the Useless Machine app in the same Fly.io organization 
* the tracker module
* the launcher live component
* per-ip rate limiting (no good against a DDoS attack but basic guardrail against a user reloading the liveview)
* autospawner
* debouncing of API status checks
* cooldown time on the launch button
* max machines
* dev dashboard with button per region 
