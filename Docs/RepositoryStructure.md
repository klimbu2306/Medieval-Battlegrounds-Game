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

The reason **why** I am using a system to track state like this, instead of using a single-state boolean variable is because any player's state is always in shared state as any other player can attack them, adding the `Stunned` marker to them. 

_Meanwhile, a boolean variable will likely result in a race-time condition_ since an algorithm to prevent invalid modifications / state changes is almost never perfect: there's always an edge case!

![<img src="Media/queue_explanation.png" alt="Queue Explanation" width="50"/>](https://github.com/klimbu2306/Medieval-Battlegrounds-Game/blob/fee404c8ac1f87620b9d50ed9a3f02c5cf61d84f/Media/queue%20diagram.png)

The solution is to sacrifice space complexity and to represent a state as a **Queue** data structure that dequeues using parallel threads.

If any new writer activates a state again, it is logically guaranteed that their state change will never be intersected / interrupted by an old writer as the data structure we use implicitly prevents interrupting new changes.

### 2. 🧮 "Raycast Hitboxing + Ability VFX"
- `ClientScripts.Ability` <-> `ServerScripts.Abilities`

`ServerScripts.Abilities` and `ClientScripts.Ability` modules work _synchronously_ to make sure the end-user is able to experience spells and attacks that make use of VFX properly.

For example, `ServerScripts.Fireball.luau` handles collision detection every frame using Raycasting + LERP'ing and `ClientScripts.FireballClient.luau` animates a fireball VFX using LERP'ing. 

Due to the fact that **both the Server and Client modules use LERP'ing algorithms**, the LERP'ing of the spell hitboxes and VFX can be synchronised to make attacks and spells seem accurately responsive. 
