#import "@preview/ilm:2.1.1": *
#import "@preview/glossy:0.9.2": *
#import "@preview/zebraw:0.6.3": *
#import "@preview/gentle-clues:1.3.1": *
#import "@preview/conch:0.1.0": system, terminal, terminal-block, terminal-frame
#import "@preview/tdtr:0.6.1": *
#import "@preview/tidymind:0.1.1": mindmap, node

// https://typst.app/universe/package/timeliney

#import "vendor/extend-citation.typ": *
#import "vendor/cite-software.typ": cite_software

#show: init-glossary.with(yaml("glossary.yaml"))

#set text(lang: "en")

#show: ilm.with(
  title: [Using NixOS for Enterprise Machine Fleets],
  abstract: [
    The availability of @llm-assisted coding tools raises a specific risk for system administration: an operator can use an @llm:short to make @ad-hoc changes directly over @root @ssh access to a live machine - "@vibe-coding" a deployment into existence with no record of what changed or why. We argue for the alternative: writing deployments locally in a @functional-language[declarative], human-readable syntax, where @llm:short assistance operates on @vcs:long rather than production state. Using @nixos, we present a project structure that is readable and extensible with ultimate goal of avoiding common pit-falls of unnecessary abstractions and out-of-scope additions; any large @module or package should be packaged in a @nixpkgs[nix-idiomatic] way; separately, and then imported as self-contained @module:pl or @package distributions.
  ],
  authors: "Joaqim Planstedt",
  bibliography: bibliography("refs.bib"),
  figure-index: (enabled: true),
  table-index: (enabled: true),
  listing-index: (enabled: true),
)

/* Testing dedicated glossary page*/
#glossary(show-all: true)

#show: zebraw

= Introduction
Creating and maintaining enterprise machines and servers is usually overtaken by in-house engineers or out-sourced to third-party providers.
In this paper, we demonstrate a declarative, human-readable project structure for a unified machine fleet deployment.

Using a declarative language for our fleet allows for transparency of intended use; no more load-
bearing @docker[docker instances] running somewhere independently of the network as a whole.

== Paper overview

// This paper does not seek to explain the @nixos ecosystem

//

#pagebreak()

= What is NixOS?

#quote(
  cite_software(<NixOS>),
) #cite_a(<wiki:NixOS>)

#[
  #set page(columns: 1)
  #pagebreak()
  = Nix module system <sec:nix-modules>

  /* Description of Nix module system with common patterns */


  == Clan

  #cite_t(<clan-core>) is a @nix @module framework and @cli that uses a @meta-framework to accomplish intrinsically linked machines while still maintaining @per-host deployments.
  /*
  #block(breakable: false)[
    #terminal-block( width: 100%,
      system: system(files: (
        "flake.nix": read("examples/flake.nix"),
        "modules/nixpkgs/default.nix": read("examples/modules/nixpkgs/default.nix")
        ,
      ),hostname: "workstation"),
      user: "user",
    )[```
    tree
    ```]
  ]*/

  === Clan secrets

  #cite_t(<clan-core>) has built-in support for secrets management, @per-host or shared secrets.

  For more in-depth guide, see #cite_t(<docs:clan-core>).

  #block(breakable: false)[
    ```nix
    clan.core.vars.generators = {
      authelia-jwt-secret = {
        files."jwt-secret" = {
          neededFor = "services";
          owner = "authelia-main";
        };
        runtimeInputs = [ pkgs.openssl ];
        script = ''
          openssl rand -hex 32 > "$out"/jwt-secret
        '';
      };
    }
    ```

    ```nix
    services.authelia = {
      enable = true;
      secrets = {
        jwtSecretFile = config.clan.core.vars.generators."authelia-jwt-secret".files."jwt-secret".path;
      };
    };

    ```
  ]

  #block(breakable: false)[
    We can also have secrets with prompt for input at deployment time:
    ```nix
    authelia-smtp-password = {
      files."password" = {
        neededFor = "services";
        owner = "authelia-main";
      };
      prompts."password" = {
        description = "SMTP relay password";
        type = "hidden";
      };
      script = ''cat "$prompts"/password > "$out"/password'';
    };
    ```

    #terminal-frame(width: 100%)[
      \$ clan vars generate workstation\ \
      Prompting value for authelia-smtp-password/password for machines: workstation\
      Leave empty to generate automatically (hidden):\
      Confirm Leave empty to generate automatically (hidden):\
    ]
  ]

  #pagebreak()
  /* More advanced and opinonated example */
  == Dendritic pattern
  The @dendritic-pattern composes a @flake from many small @flake-parts @module:pl with no manual import lists.
  The following examples are taken from #cite_atyp(<vanixiets>) project, which combines @deferred-module-composition patterns with first-class support for @clan @module:pl and related @cli[tools].


  @flake-nix is a thin trunk:
  #raw(read("examples/flake.nix"), lang: "nix", block: true)

  ```nix import-tree ./modules``` walks the directory and returns a @flake-parts module whose effect is ```nix { imports = [ ...every discovered .nix... ]; }```.

  @flake-parts loads that list with: ```nix lib.evalModules { class = "flake"; ... }```, so all discovered files merge into one module-system.

  #block(breakable: false)[
    Adding a new module or configuration means creating a `.nix` file anywhere inside `modules/*`; there are no @import-list:pl or @barrel-file:pl to maintain.

    // #raw(read("examples/modules/nixpkgs/base-defaults.nix"), lang: "nix", block: true)

    This is a minimally viable `modules.nixos` definition:
    ```nix
    { inputs, ... }:
    {
      flake.modules.nixos.alexandria = inputs.alexandria.nixosModules.default;
    }
    ```

    See @nixos-conf for @host @code:host-desktop[`desktop`] where #cite_t(<alexandria>) @module is imported on a @per-host basis.
  ]

  #block(breakable: false)[
    More advanced example, which include pre-configured options:
    ```nix
    { inputs, ... }:
    {
      flake.modules.nixos.pixelstreaming =
        { pkgs, ... }:
        {
          imports = [ inputs.pixelstreaming.nixosModules.default ];
          services.pixelstreaming-signaller = {
            enable = true;
            playerPort = 8080;
            streamerPort = 8888;
            openFirewall = true;
          };
        };
    }
    ```
  ]

  And for @per-host inclusion:
  #figure(
    ```nix
    {
      flake.modules.nixos."machines/nixos/desktop" =
        {
          config,
          pkgs,
          lib,
          ...
        }:
        {
          imports = (with config.flake.module.nixos; [
            alexandria
            pixelstreaming
          ]);

          # Since our minimal alexandria module doesn't have any configuration
          # let's declare it here
          services.alexandria.enable = true;

          # Optionally, we can also override our own module defaults
          services.pixelstreaming-signaller.openFirewall = lib.mkForce false;
        };
    }
    ```,
  ) <code:host-desktop>

  #figure(
    caption: [Tree graph of @import-tree[`import-tree`] relations],
  )[
    #tidy-tree-graph(json("tree.json"))
  ]

  For best useability, these modules would be defined in separate files, but the could also be defined in-place anywhere in `./modules/**/*.nix`:
  #zebraw(numbering: false)[
    ```nix
     # modules/nixos/gnome/default.nix
     flake.modules.nixos."gnome" = {config, ... }:
      config = {
        services.desktopManager.gnome.enable = true;
        services.displayManager.gdm.enable = true;
      };
     };
     # modules/home/gnome/default.nix
     flake.modules.homeManager."gnome" = {config, ... }: {
       config.gnome.enable = true;
     };
     # modules/home/users/user1/default.nix
     flake.modules.homeManager.users."user1" = {config, ...}: {
      config.dconf.settings = {
        "org/gnome/desktop/media-handling" = {
          automount = false;
          automount-open = false;
        };
      };
    };
    ```
  ]

  In rare circumstances where you don't want `*.nix` files under `./modules` to be implicitly loaded as @flake-module[`flake-modules`], follow naming convention where  `_*.nix` gets skipped automatically by @import-tree[`import-tree`].

  Preferably, for cases of stand-alone `.nix` files, use top-root directories outside of `./modules` instead, such as `./lib`, where applicable.

  #block(breakable: false)[
    *References as initial source of @dendritic-pattern:pl:*

    #cite_atyp(<dendritic-implementation>)

    #cite_atyp(<refactoring-my-infrastructure-as-code-configurations>)

    #cite_atyp(<the-dendritic-pattern>)
  ]


  /*
  #mindmap(
    node([Order is Packed],
    node([Purchase Label for Shipping],
    [Add Tracking information],
    [Upload ZPL/PDF Label to Order]
    ),
    node([Create new Parcel for Order]),
    node([#strike[Update existing Parcel]])
    ),
  )*/
]

