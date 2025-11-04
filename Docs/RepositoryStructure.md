## 🐉⚙️ Docx #1: Repository Structure!
### 📝 Preface
Please view the `README.md` file before reading this documentation, as it will give you a brief introduction to this document's contents. 

---
### 🔍 Overview 
`RepositoryStructure.md` has been written to explain the black-box nature of how each directory tends to interact with one another, sometimes across the `ServerScripts` and `ClientScripts` boundaries.

This document will now provide examples of how modules were intended to interact with each other.

---

### 1. 🔐 "State Management + Server Validation"
- `ServerScripts.Physics` <-> `ServerScripts.Abilities`

`ServerScripts.Abilities` is responsible for validating whether a client is _supposed_ to be able to use an ability before they do! 

However, in order to do this, the state of the player must be **accurately** managed, which is done through the `ServerScripts.Physics` modules. 

For example, `ServerScripts.Physics.Stun.luau` is a system used to tag a player with a `Stunned` marker, which has a parallel thread that removes it after a certain given amount of time. 

The system allows for any given player to be _tagged multiple times_, since the player's state is technically in shared state as any other player can attack them, adding the `Stunned` marker to them. 

The issue is that in many systems, _this can result in race time condition errors_ if we were to use a single shared-state boolean variable to track the player's `Stunned` state. 

With a boolean variable, shared-state or private, you _risk the aforementioned racetime condition error_ if your system messes up preventing multiple people from being able to overwrite the variable when they aren't supposed to!

![<img src="Media/queue_explanation.png" alt="Queue Explanation" width="50"/>](https://github.com/klimbu2306/Medieval-Battlegrounds-Game/blob/fee404c8ac1f87620b9d50ed9a3f02c5cf61d84f/Media/queue%20diagram.png)

The fix is to sacrifice space complexity and use a **Queue** data structure, which is where `ServerScripts.Abilities` intersects with `ServerScripts.Physics` by having it's verification system revolve around *checking whether a state queue is empty to verify whether a player is in a given state or not*

Essentially, if `ServerScript.Abilities` wanted to validate whether a player could use a spell, they would make sure that every state that disqualifies them from using that spell has an empty queue.

### 2. 🧮 "Raycast Hitboxing + Ability VFX"
- `ClientScripts.Ability` <-> `ServerScripts.Abilities`

`ServerScripts.Abilities` and `ClientScripts.Ability` modules work _synchronously_ to make sure the end-user is able to experience spells and attacks that make use of VFX properly.

For example, `ServerScripts.Fireball.luau` handles collision detection every frame using Raycasting + LERP'ing and `ClientScripts.FireballClient.luau` animates a fireball VFX using LERP'ing. 

Due to the fact that **both the Server and Client modules use LERP'ing algorithms**, the LERP'ing of the spell hitboxes and VFX can be synchronised to make attacks and spells seem accurately responsive. 
