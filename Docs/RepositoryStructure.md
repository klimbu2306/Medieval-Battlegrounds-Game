er## 🐉⚙️ Docx #1: Repository Structure!
### 📝 Preface
Please view the `README.md` file before reading this documentation, as it will give you a brief introduction to this document's contents. 

---
### 🔍 Overview 
`RepositoryStructure.md` has been written to explain the black-box nature of how each directory tends to interact with one another, sometimes across the `ServerScripts` and `ClientScripts` boundaries.

This document will now provide examples of how modules were intended to interact with each other.

---

### 1. 🧮 "Raycast Hitboxing + Ability VFX"
- `ClientScripts.Ability` <-> `ServerScripts.Abilities`

`ServerScripts.Abilities` and `ClientScripts.Ability` modules work _synchronously_ to make sure the end-user is able to experience spells and attacks that make use of VFX properly.

For example, `ServerScripts.Fireball.luau` handles collision detection every frame using Raycasting + LERP'ing and `ClientScripts.FireballClient.luau` animates a fireball VFX using LERP'ing. 

Due to the fact that **both the Server and Client modules use LERP'ing algorithms**, their LERP'ing of the hitbox and VFX can be synchronised to make attacks and spells seem accurately responsive. 

### 2. 🔐 "Finite State Management + Server Validation"
- `ServerScripts.Physics` <-> `ServerScripts.Abilities`
