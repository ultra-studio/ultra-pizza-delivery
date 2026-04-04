# Ultra Studio Pizza Job

> Ultra Studio - Free Resource  
> Version: v1.0.1  
> (c) 2026 Ultra Studio. All rights reserved.

## 📸 Preview
<div align="center">
  <img src="https://media.discordapp.net/attachments/1487828118562541729/1488642654052028537/ultra_pizza_job.png?ex=69cd8602&is=69cc3482&hm=7cfa4d52865f326a56522a0a589fe54401d104abe3eeb54ab92e13e8ec5dbdef&=&format=webp&quality=lossless&width=1006&height=561" width="80%" />
</div>

`Ultra Studio Pizza Job` is a free FiveM delivery job resource built for servers that want a lightweight pizza delivery gameplay loop with clean framework bridges and a professional structure.

This resource is free to use, but it cannot be resold or redistributed without permission from Ultra Studio.

## Features

- Structured `client`, `server`, `config`, and `docs` folders
- Configurable boss NPC, vehicle, payouts, and delivery locations
- Support-ready bridge files for `QBCore`, `ESX`, and `ND_Core`
- Delivery route flow with blips, target zones, payment callbacks, and exploit checks
- Cleaned and documented codebase prepared for public GitHub release

## Installation Steps

1. Download or clone the resource into your server's `resources` folder.
2. Rename the folder if needed, then ensure the resource name stays consistent with your server setup.
3. Make sure dependencies are installed:
   - `ox_lib`
   - `qb-target`
   - One supported framework bridge:
     - `qb-core`
     - `es_extended`
     - `ND_Core`
   - `mysql-async`
4. Add the resource to your `server.cfg`:

```cfg
ensure ultra_pizzajob
```

5. Edit shared settings in `config/shared.lua`.
6. Edit server-side payouts, vehicle settings, and delivery locations in `config/server.lua`.
7. Restart the server or run `refresh` followed by `ensure ultra_pizzajob`.

## Usage

- Go to the pizza job boss location.
- Start a shift from the interaction target.
- Use the delivery scooter to collect and deliver pizzas.
- Finish the shift at the boss NPC when all deliveries are complete or when you want to stop.

## Links

- Discord: https://discord.gg/QmgpkZembx
- GitHub: https://github.com/ultra-studio

## 🎥 Video Tutorial

<div align="center">
  <a href="https://youtu.be/MGRkdGkaCGE">
    <img src="https://img.youtube.com/vi/MGRkdGkaCGE/maxresdefault.jpg" width="80%" />
  </a>
</div>


### 🔧 Fixes
- Fixed error in shared.lua
- Improved script stability (dependency guards, model hash handling, config string fix)

## License

Free for personal use. Commercial use requires permission. See [LICENSE](LICENSE) for full terms.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for release notes.


