# Ecto embedded schemas from a JSON OpenAPI spec

Fair warning: This is spaghetti mixed with salad. I used Claude iteratively (plus ChatGPT and Gemini occasionally) to push my way through this. _Also,_ it wasn't made from first principles. Claude and I reverse-engineered a specific API's OpenAPI spec from [doc.machines.dev](https://docs.machines.dev), so who knows if it generalizes to any other API!

## Usage

```
mix build_schemas <input-file> <output-dir>
```

The input file must contain an OpenApi spec in JSON format.

## Reasons for building this

* Sheer mule-headedness (mainly)
* To practice LLM prompting and generally finding ways to augment my work with models
* To learn about Elixir and Ecto
* To let me validate request bodies I pass as maps to [Christian Kreiling](https://github.com/ckreiling)'s [Elixir client for the Fly Machines API](https://github.com/ckreiling/fly_machines).

## What it does (if it's working right)

* Takes a json spec filename and an output directory name
* For each component/schema it finds in the spec, writes a schema module file with an embedded schema and changeset 

## Cases it tries to handle

The MachinesApiToEcto module looks for:

* regular fields and their types
* regular embedded references
* `additionalProperties` and references within
* `allOf` and references within

And tries, for each component, to
* generate an embedded schema  
* generate `cast/4`, `cast_embed`, and `validate_required` calls on changesets

## What it doesn't do

* Anything at all with the paths; i.e. it doesn't write anything to build requests or check their path parameters.
* Exclude things you'd never want to generate or validate as a consumer of an API, like stuff that'll show up in responses. IDK, maybe you'd want to know what might be in there. But it's a lot of extra files.
* Document anything
* Have tests

If I wanted to validate keyword parameters, I would explore Nimble Options

## What to do with the output

Manually edit any schema modules you're going to use as necessary. 
For example, at the time of writing, the Fly Machines API makes extensive use of descriptions, but not anything like a `"required"` field, to indicate that a property is, in fact, required. So if I want my app to use changesets to check that I haven't forgotten an `"image"` in my Machine `"config"`, I have to go to the `FlyApi.FlyMachineConfig` module and add `|> validate_required([:image])` to the changeset definition.

## Things I was shaky on before starting

* Ecto: embedded schemas, changesets, and general critical eye on syntax 
* What's in an OpenAPI spec and how references work within them
* The best way to validate a schema like this

## Other things I tried

* the openapi tool for generating a client--I already had a client; I wanted validation more
* generating schemas for Nimble Options, which is for nested keyword lists but might still work for an API like this (I wasn't sure if that would be to the point so switched to Ecto, but I'd like to try it again; I like the documentation possibilities)
* https://github.com/open-api-spex/open_api_spex (didn't descend far enough into the nested references I think.)