# arbify

[![pub package][pub-package-badge]][pub-package]
[![Flutter workflow][flutter-workflow-badge]][flutter-workflow]

A package providing support for internationalizing Flutter applications using [intl] package with [Arbify].

## Usage

```bash
$ flutter pub run arbify:download --help
Arbify download command-line utility.
-h, --help                Shows this help message.
-i, --[no-]interactive    Whether the command-line utility can ask you interactively.
                          (defaults to on)
-s, --secret=<secret>     Secret to be used for authenticating to the Arbify API.  
                          Overrides the secret from the .secret.arbify file. 
```

Use `flutter pub run arbify:download` to run a command-line utility that will guide you through setting up arbify package. This generally comes to two things:

1. Adding configuration to your `pubspec.yaml` file

        arbify:
          url: https://arb.company.com
          project_id: 17
          outpur_dir: lib/l10n # default, can be ommited

2. Adding your secret (obtained at https://arb.company.com/account/secrets/create) to `.secret.arbify` file.

[pub-package]: https://pub.dev/packages/arbify
[pub-package-badge]: https://img.shields.io/pub/v/arbify
[flutter-workflow]: https://github.com/Arbify/arbify_flutter/actions?query=workflow%3AFlutter
[flutter-workflow-badge]: https://img.shields.io/github/workflow/status/Arbify/arbify_flutter/Flutter
[intl]: https://pub.dev/packages/intl
[Arbify]: https://github.com/Arbify/Arbify
