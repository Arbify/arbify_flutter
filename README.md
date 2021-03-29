# arbify

[![pub package][pub-package-badge]][pub-package]
[![Flutter workflow][flutter-workflow-badge]][flutter-workflow]

A wrapper of [intl_utils](https://pub.dev/packages/intl_utils). Provides your translations server instead of `localizely` server

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

    ```yaml
    arbify:
      url: https://arb.company.com
      project_id: 17
      outpur_dir: lib/l10n # default, can be omitted
    ```

    Additional configs from [intl_utils](https://pub.dev/packages/intl_utils):
    ```yaml
    flutter_intl:
      enabled: false # Required. If true IDE plugin will watch changes of files and generate it by itself
      class_name: S # Optional. Sets the name for the generated localization class. Default: S
      main_locale: en # Optional. Sets the main locale used for generating localization files. Provided value should consist of language code and optional script and country codes separated with underscore (e.g. 'en', 'en_GB', 'zh_Hans', 'zh_Hans_CN'). Default: en
      arb_dir: lib/l10n # Optional. Sets the directory of your ARB resource files. Provided value should be a valid path on your system. Default: lib/l10n
      output_dir: lib/generated # Optional. Sets the directory of generated localization files. Provided value should be a valid path on your system. Default: lib/generated
      use_deferred_loading: false # Optional. Must be set to true to generate localization code that is loaded with deferred loading. Default: false
    ```

2. Adding your secret (obtained at https://arb.company.com/account/secrets/create) to `.secret.arbify` file.

### Sample output

```bash
$ flutter pub run arbify:download

Output directory doesn't exist. Creating... done.
en                  Downloading... done.
pl                  Downloading... done.
mk                  Downloading... done.
Generating l10n.dart file... done 
Generating messages dart files... done
```

[pub-package]: https://pub.dev/packages/arbify
[pub-package-badge]: https://img.shields.io/pub/v/arbify
[flutter-workflow]: https://github.com/Arbify/arbify_flutter/actions?query=workflow%3AFlutter
[flutter-workflow-badge]: https://img.shields.io/github/workflow/status/Arbify/arbify_flutter/Flutter
[intl]: https://pub.dev/packages/intl
[Arbify]: https://github.com/Arbify/Arbify
