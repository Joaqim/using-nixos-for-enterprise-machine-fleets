#import "@preview/ilm:2.1.1": *
#import "@preview/glossy:0.9.2": *
#import "@preview/zebraw:0.6.3": *
#import "@preview/gentle-clues:1.3.1": *
#import "@preview/conch:0.1.0": system, terminal, terminal-block, terminal-frame
#import "@preview/tdtr:0.6.1": *
#import "@preview/tidymind:0.1.1": mindmap, node
#import "@preview/dtree:0.1.1": dtree

#let nix-icon = read("assets/Nix_snowflake.svg", encoding: none);
#let folder-icon = "📁"
#let secrets-icon = "🔒"
#let dtree-icons = (
  "nix": nix-icon,
  "dir": folder-icon,
)
#let dtree-icon-rules = (
  (regex("/$"), "dir"),
  ("*.nix", (icon: "nix", fill: blue)),
)

// https://typst.app/universe/package/timeliney

#import "vendor/extend-citation.typ": *
#import "vendor/cite-software.typ": cite_software, cite_title

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

  For a simple introduction to @nix-module[Nix module system], see: #cite_title(<nixdev:a-basic-module>)

  /* Description of Nix module system with common patterns */
  #quote(attribution: [#cite_atyp(<nixdev:a-basic-module>)])[
    The simplest possible module is a function that takes any attributes and returns an empty attribute set:
  ]

  ```nix
  { ... }:
  {
  }
  ```
  For the purposes of this paper, @flake-module:pl can look like this:
  ```nix
  { ... }: {
    # A NixOS module for a custom systemd service
    flake.modules.nixos.my-service = { config, lib, ... }:
      let
        cfg = config.services.my-service;
      in
    {
      options.services.my-service = {
        enable = lib.mkEnableOption "my custom service";
      };
      config = lib.mkIf cfg.enable {
        systemd.user.services.my-service = {
          description = "my custom service";
          wantedBy = [ "default.target" ];
          serviceConfig.ExecStart = lib.getExe pkgs.my-package;
        };
      };
    };
  ```
  #zebraw(numbering: false)[
    A @darwin (@macos) @module—out of scope for this paper.
    ```nix
      {...}: {
        flake.modules.darwin.my-module = { ... }: {
        };
      }
    ```
    A @home-manager @module
    ```nix
      {...}: {
        flake.modules.home.my-module = { ... }: {
        };
      }
    ```
    A @flake-module
    ```nix
      {...}: {
        # A flake module
        flake.modules.flake.my-module = { ... }: {
        };
      }
    ```
  ]

  The naming choice should be driven by aspect rather than conforming to established patterns, see @deferred-module-composition.

  #block(breakable: false)[
    For more in-depth guides:
    - #cite_t(<nixdev:a-basic-module>)
    - #cite_t(<nlewo:nixos-manual:writing-nixos-modules>)
  ]

  == Project structure

  We utilize @dendritic-pattern and @flake-parts with @flake-module:pl, see @sec:dendritic-pattern.

  Naming and folder structure conventions are wholly up to the operator as @import-tree is not distriminatory; any `.nix` file under assigned import directory will be implicitly supported, unless otherwise excluded, see @sec:excluded-nix-files.

  We recommend using nix-idiomatic `default.nix` and sub-folder structures in direct relation with @flake-module patterns.

  @nix draws no distinction between unquoted and quoted attributes;
  `flake.modules.<class>.<name>` and `flake.modules.<class>."<name>"` are equivalent.

  We recommend using quoted attributes where the attribute root would be semantically equivalent to `flake.modules.class."<name>".name = "<name>"`, see `"user1"` in examples below.

  #zebraw(numbering: false)[
    ```nix
     # modules/nixos/gnome/default.nix
     flake.modules.nixos.gnome = {config, ... }:
      config = {
        services.desktopManager.gnome.enable = true;
        services.displayManager.gdm.enable = true;
      };
     };
     # modules/home/gnome/default.nix
     flake.modules.homeManager.gnome = {config, ... }: {
       config.gnome.enable = true;
     };
     # modules/home/users/user1/gnome.nix
     flake.modules.homeManager.users."user1" = {config, ... }: {
      config.dconf.settings = {
        "org/gnome/desktop/media-handling" = {
          automount = false;
          automount-open = false;
        };
      };
     };
    ```
  ]

  #pagebreak()

  This is a minimally viable `modules.nixos` definition, using externally defined @nix-module, which is a @flake-input:
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

=== File tree example <sec:file-tree-example>

#block(breakable: false)[
  #dtree(
    icons: dtree-icons,
    icon-rules: dtree-icon-rules,
    ```
    flake.nix
    modules/
      machines/nixos/
        workstation/
          default.nix
        server-1/
          default.nix
      nixos/
        gnome/
          default.nix
        ssh/
          default.nix
      home/
        users/
          user1/
            default.nix
            gnome.nix
          admin/
            default.nix
            ssh.nix
        gnome/
          default.nix
        terminal/
          default.nix
    ```,
  )
]

=== Tree graph example <sec:tree-graph-example>
#figure(
  caption: [Example of a tree graph of @import-tree[`import-tree`] imports and @nix[nix-evaluated] relations.],
)[
  #tidy-tree-graph(json("tree.json"))
]

#pagebreak()

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
/* More advanced and opinionated example */
== Dendritic pattern <sec:dendritic-pattern>
The @dendritic-pattern composes a @flake from many small @flake-parts @module:pl with no manual import lists.
The following examples are taken from #cite_atyp(<vanixiets>) project, which combines @deferred-module-composition patterns with first-class support for @clan @module:pl and related @cli[tools].


@flake-nix is a thin trunk:
#raw(read("examples/flake.nix"), lang: "nix", block: true)

```nix import-tree ./modules``` walks the directory and returns a @flake-parts module whose effect is ```nix { imports = [ ...every discovered .nix... ]; }```.

@flake-parts loads that list with: ```nix lib.evalModules { class = "flake"; ... }```, so all discovered files merge into one @nix-module[Nix module system].

#block(breakable: false)[
  Adding a new module or configuration means creating a `.nix` file anywhere inside `modules/*`; there are no @import-list:pl or @barrel-file:pl to maintain.

  // #raw(read("examples/modules/nixpkgs/base-defaults.nix"), lang: "nix", block: true)
]

=== Excluded .nix files <sec:excluded-nix-files>
In rare circumstances where you don't want `*.nix` files under `./modules` to be implicitly loaded as @flake-module[`flake-modules`], we recommend the operator to follow naming conventions where `_*.nix` already automatically gets skipped by @import-tree[`import-tree`].

For cases where `.nix` files—for usability outside a @flake-module pattern—use top-root directories outside of `./modules` instead, such as `./lib`, or wherever is most applicable.

#block(breakable: false)[
  === References as initial originators of @dendritic-pattern[dendritic patterns]
  This is a non-exhaustive list of the posts, repositories and discussions where the @dendritic-pattern where first established [_sic_].

  #cite_atyp(<dendritic-implementation>)

  #cite_atyp(<refactoring-my-infrastructure-as-code-configurations>)

  #cite_atyp(<the-dendritic-pattern>)
]

== @flake-parts[Flake-parts and the module system]

#warning[
  This section and related sub-sections was taken wholesale from #cite_atyp(<vanixiets>).

  #link(
    "https://github.com/cameronraysmith/vanixiets/blob/4ab001b3268dffd77c5de99264f9ae031b5fa134/packages/docs/src/content/docs/concepts/flake-parts-module-system.md",
  )[see `./docs/concepts/flake-parts-module-system.md`]

  It is also probably machine-written text, pending re-write.
]


@flake-parts[Flake-parts] provides ergonomic access to the @nix-module[Nix module system] for creating @flake:pl.
It wraps `lib.evalModules` to evaluate @module:pl with specialized abstractions for @flake-output:pl, @per-system evaluation, and @module publication.
Understanding what @flake-parts adds on top of the base module system is critical for working with @deferred-module-composition architectures.

=== What flake-parts provides

Flake-parts is not a replacement for the module system, but a specialized framework that adds flake-specific conveniences on top of nixpkgs `lib.evalModules`.
These conveniences handle the boilerplate of creating flake outputs while preserving the composability of the underlying module system.

==== The perSystem abstraction

The `perSystem` option eliminates manual iteration over system types when defining per-architecture outputs.
Instead of writing repetitive code for each system string (`"x86_64-linux"`, `"aarch64-darwin"`, etc.), you define packages, apps, and checks once in a perSystem module.

```nix
{ ... }:
{
  perSystem = { config, pkgs, system, ... }: {
    packages.hello = pkgs.writeShellScriptBin "hello" ''
      echo "Hello from ${system}"
    '';
  };
}
```

Flake-parts automatically evaluates this module for each system listed in the `systems` option, producing system-specific configurations that get transposed into flake outputs like `packages.<system>.hello`.

==== The flake.modules namespace

The `flake.modules` option creates a conventional namespace for publishing deferred modules that can be consumed by other configurations (NixOS, nix-darwin, home-manager).
This enables flakes to export modules as reusable components.

```nix
{ ... }:
{
  flake.modules.nixos.my-service = { config, lib, pkgs, ... }: {
    options.services.my-service.enable = lib.mkEnableOption "my service";
    config = lib.mkIf config.services.my-service.enable {
      systemd.services.my-service = { /* ... */ };
    };
  };
}
```

Consumers can then import these modules in their own configurations:

```nix
{
  inputs.our-flake.url = "github:org/repo";
  outputs = { nixpkgs, our-flake, ... }: {
    nixosConfigurations.host = nixpkgs.lib.nixosSystem {
      modules = [
        our-flake.modules.nixos.my-service
        { services.my-service.enable = true; }
      ];
    };
  };
}
```

The namespace structure is `flake.modules.<class>.<name>` where `class` identifies the module system context (nixos, darwin, homeManager, generic, flake) and `name` is the module identifier.

==== Automatic transposition

The transposition module automatically merges per-system attributes from `perSystem` evaluations into conventional flake output locations.
When you define `packages.hello` in a perSystem module, flake-parts creates `flake.packages.<system>.hello` for each system without explicit configuration.

This handles the mapping from per-system configurations to the flat attribute structure expected by flake outputs.

==== System-specific context access

The `withSystem` and `moduleWithSystem` helpers provide escape hatches for accessing system-specific context in top-level flake modules.
These bridge the gap between flake-level (class `"flake"`) and perSystem-level (class `"perSystem"`) evaluation contexts.

=== Two-layer evaluation model

Flake-parts evaluates modules in two distinct layers, each using `lib.evalModules` with different module classes.

==== Top-level flake evaluation

The first layer evaluates modules with class `"flake"` to produce the overall flake structure:

```nix
# From flake-parts lib.nix
lib.evalModules {
  specialArgs = {
    inherit self flake-parts-lib moduleLocation;
    inputs = args.inputs or self.inputs;
  } // specialArgs;
  modules = [ ./all-modules.nix module ];
  class = "flake";
}
```

This evaluation creates a module system context where:
- The `flake` option accumulates all output attributes
- The `perSystem` option holds deferred modules for per-system evaluation
- The `systems` option lists architectures to enumerate
- The `flake.modules` namespace publishes modules for external consumption

The final flake outputs come from extracting `config.flake` after this evaluation completes.

==== Per-system evaluation

For each system in the `systems` list, flake-parts evaluates the deferred modules from `perSystem` with class `"perSystem"`:

```nix
# From flake-parts modules/perSystem.nix
(lib.evalModules {
  inherit modules;
  prefix = [ "perSystem" system ];
  specialArgs = { inherit system; };
  class = "perSystem";
}).config
```

Each per-system evaluation receives:
- The specific `system` string as a module argument
- System-specific input views via `inputs'` and `self'`
- Access to `config`, `pkgs`, and other perSystem options

The `allSystems` option memoizes these evaluations as a mapping from system strings to perSystem configurations.
The transposition module then merges these configurations into the top-level flake outputs.

=== Module classes in flake-parts

Module classes prevent accidental mixing of modules from incompatible contexts.
The nixpkgs module system supports classes via the `class` parameter to `evalModules` and the `_class` module attribute.

Flake-parts uses two primary module classes:

- *`"flake"`* - Top-level flake-parts modules that define `flake`, `perSystem`, `systems` options
- *`"perSystem"`* - Per-system modules evaluated with specific system context

The `flake.modules` namespace supports publishing modules for external classes:

- *`nixos`* - NixOS system modules
- *`darwin`* - nix-darwin system modules
- *`homeManager`* - home-manager user modules
- *`generic`* - Class-agnostic modules that work in any context
- *`flake`* - Nested flake-parts modules

When you define `flake.modules.nixos.my-module`, flake-parts automatically wraps it with `_class = "nixos"` metadata to ensure type safety.

=== The deferredModule type

The `flake.modules` option uses the `deferredModule` type to delay evaluation until the consumer calls `evalModules` with the appropriate class.
This type is a nixpkgs primitive, not a flake-parts invention.

The type is defined as `lazyAttrsOf (lazyAttrsOf deferredModule)`:
- First level: module class (nixos, darwin, homeManager, generic, flake)
- Second level: module name
- Value: deferred module content

A deferred module accepts attribute sets, functions, or paths as module definitions and merges them by concatenating into a module list.
The actual evaluation happens when a consumer imports the module into their own `evalModules` call.

```nix
# Publishing side (flake-parts)
flake.modules.nixos.example = { config, lib, ... }: {
  options.foo = lib.mkOption { type = lib.types.str; };
};

# Consuming side (NixOS configuration)
nixpkgs.lib.nixosSystem {
  modules = [
    inputs.our-flake.modules.nixos.example
    { foo = "bar"; }
  ];
}
```

This pattern enables module composition across flake boundaries without premature evaluation.

=== How deferred module composition builds on flake-parts

Deferred module composition uses flake-parts as its integration layer for producing flake outputs, but extends it with auto-discovery and structured module organization.

Key additions in deferred module composition architectures:

- *import-tree for auto-discovery* - Automatically discovers and imports modules from directory structures
- *Namespace sharding* - Organizes modules by concern (configurations, modules, packages, systems)
- *Hierarchical composition* - Modules at each level contribute to merged outputs

These are organizational patterns specific to aspect-based deferred module composition architectures, not features of flake-parts itself.
The deferred module composition pattern fundamentally relies on deferred modules (a module system primitive), uses flake-parts for ergonomic flake integration, and adds its own conventions for module discovery and composition.

For details on the underlying module system primitives, see [Module system primitives](/concepts/module-system-primitives/).
For details on the deferred module composition pattern, see [Deferred module composition](/concepts/deferred-module-composition/).

=== Flake-parts is optional

The deferred module composition organizational pattern does not require flake-parts.
Deferred modules are a nixpkgs primitive available through `lib.evalModules`, and you can evaluate them directly without any flake framework.
Flake-parts provides convenient abstractions for flake integration, but the underlying module composition mechanisms work independently.

==== Direct evalModules usage

A minimal example demonstrating direct evaluation without flake-parts:

```nix
# services/database.nix - A deferred module
{ config, lib, ... }:
{
  options.database = {
    enabled = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable database service";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 5432;
      description = "Database port";
    };
  };

  config = lib.mkIf config.database.enabled {
    # Service configuration would go here
  };
}

# evaluation.nix - Direct evalModules call
let
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;

  # Evaluate modules directly
  result = lib.evalModules {
    modules = [
      ./services/database.nix
      { database.enabled = true; }
      { database.port = 3306; }
    ];
  };
in
{
  inherit (result) config options;
  # result.config.database.enabled => true
  # result.config.database.port => 3306
}
```

This demonstrates the core composition mechanism: `evalModules` accepts a list of deferred modules, merges their option declarations and config definitions, computes the fixpoint where `config` refers to the final merged state, and returns the evaluated configuration.

==== What flake-parts adds

Flake-parts builds on this foundation with flake-specific abstractions:

- *perSystem evaluation* - Automatically evaluates modules for each system in `systems` list, eliminating manual per-architecture iteration
- *Namespace conventions* - `flake.modules.<class>.<name>` provides conventional publishing structure for reusable modules
- *Transposition* - Merges per-system configurations into flat flake output schema (`packages.<system>.name`)
- *Two-layer evaluation* - Separates flake-level concerns (class `"flake"`) from per-system concerns (class `"perSystem"`)
- *Type safety* - Module classes via `_class` attribute prevent mixing incompatible module contexts

==== When to use each approach

*Use raw evalModules when:*
- You need maximum control over evaluation parameters
- Your use case doesn't fit the two-layer (flake + perSystem) model
- You're learning module system fundamentals
- You're building custom evaluation contexts (not flake outputs)

*Use flake-parts when:*
- You're producing flake outputs with per-system variants
- You want to publish reusable modules with namespace conventions
- You need the perSystem abstraction to avoid boilerplate
- You're integrating with the broader flake-parts ecosystem

*Use deferred module composition when:*
- You have complex multi-machine configurations
- You want aspect-based organization with auto-discovery
- You need hierarchical module composition across platforms
- You're managing fleets with shared cross-cutting concerns

The choice depends on your organizational needs and whether flake-parts' opinionated structure matches your use case.

=== External references

- [Flake-parts documentation](https://flake.parts) - Official flake-parts reference
- [Nixpkgs module system](https://nixos.org/manual/nixpkgs/stable/#module-system) - Base module system documentation
- [Module classes RFC](https://github.com/NixOS/rfcs/pull/146) - Design rationale for module classes
- [deferredModule in nixpkgs](https://github.com/NixOS/nixpkgs/pull/163617) - Implementation of deferred module type


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

