# WhereMachines

WhereMachines is a Phoenix LiveView application that provides a button to launch small virtual machines of no practical use on the cloud compute platform [Fly.io](https://fly.io). Its companion project is UselessMachine, a Phoenix LiveView application of no practical use that's easily launched in a virtual machine on Fly.io.

## Why?

I wanted to exercise a bunch of Fly.io features in a learning project. I was inspired by [Where Durable Objects Live](https://where.durableobjects.live/), a much more ambitious project. When 
you visit that site, it triggers the creation of a short-lived Cloudflare Durable Object. 



A LiveView application ...


* initial UI with 
  * the region the request comes from
  * a button to 
    * launch a Machine in the nearest region to that (hmmm, that's harder than top1.nearest.of from the edge instance, if I don't run it in every region) (maybe do the simpler thing here)
    * send itself an HTTP request to fly-replay to the new Machine
  
* function to 
  * do an API call to start the new machine 
  * do an API call to wait for the Machine?
  * compose a fly-replay header
  * make an HTTP request to self (req?)
  * replay the request to the new Machine


* Need a module to define the config(s) for Machines to start.
* 

* Config for Useless Machine
  * proxy services config
  * whatever else in fly.toml for useless-machine-whatever deployed app
