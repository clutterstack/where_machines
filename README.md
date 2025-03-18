# WhereMachines

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
