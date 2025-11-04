# 🐉 Medieval Era Battleground (Open-Source Project)

**"Medieval Era Battlegrounds"** is a 3D videogame I developed as a passion project during my gap year.

### 🖥️ Repository Structure Overview
---
Inside the repo, instead of a `src` folder, there are two main branching `src` folders:

1. `ServerScripts` (for Networking, Data, Security)

2. `ClientScripts` (for Physics Simulation, VFX, UI / UX Interface)

Within `ServerScripts` and `ClientScripts` there are further _sub-directories_ that contain modules - and **importing this repo requires that you place code in the exact directories that have been specified!**

### 📂 Connection between ServerScripts and ClientScripts
---

Within `ServerScripts` and `ClientScripts` there are many folders which share the same name and are _directly related to each other_!

For example, `ClientScripts.Ability` and `ServerScripts.Abilities` work together (with `ClientScripts` handling VFX, and `ServerScripts` handling network logic and verification). 

This is made clearer through naming conventions like:

- `ClientsScripts.Ability.FireballClient.luau` and `ServerScripts.Abilities.Fireball.luau`

Typically, `ServerScripts` are executed first, before their `ClientScripts` equivalents are executed!

_(More information can be found within the documentation!)_

### 🖼️ Media Assets
---
Additionally, an `Assets` folder has been included for the UI / UX and 3D Assets used within the game.

_(All character models have been developed by me, using Blender, and are free to use! However, other 3D assets / 2D UI icons have been developed by other people, so please double-check when trying to use them!)_
