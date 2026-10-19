Run flutter build web --release --base-href "/rezoplus-csu/"
Compiling lib/main.dart for the Web...                          
Wasm dry run findings:
Found incompatibilities with WebAssembly.

package:rezoplus_csu/main.dart 2:1 - dart:html unsupported (0)

Consider addressing these issues to enable wasm builds. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm

Use --no-wasm-dry-run to disable these warnings.
Target dart2js failed: ProcessException: Process exited abnormally with exit code 1:
lib/main.dart:62:3:
Error: Type 'html.AudioContext' not found.
  html.AudioContext? _audioContext;
  ^^^^^^^^^^^^^^^^^
lib/main.dart:62:8:
Error: 'AudioContext' isn't a type.
  html.AudioContext? _audioContext;
       ^^^^^^^^^^^^
lib/main.dart:86:30:
Error: Method not found: 'AudioContext'.
      _audioContext ??= html.AudioContext();
                             ^^^^^^^^^^^^
Error: Compilation failed.
  Command: /opt/hostedtoolcache/flutter/stable-3.47.7-x64/flutter/bin/cache/dart-sdk/bin/dart compile js --platform-binaries=/opt/hostedtoolcache/flutter/stable-3.47.7-x64/flutter/bin/cache/flutter_web_sdk/kernel --invoker=flutter_tool -Ddart.vm.product=true -DFLUTTER_BUILD_NAME=1.0.0 -DFLUTTER_BUILD_NUMBER=1 -DFLUTTER_VERSION=3.47.7 -DFLUTTER_CHANNEL=stable -DFLUTTER_GIT_URL=https://github.com/flutter/flutter.git -DFLUTTER_FRAMEWORK_REVISION=abaf9c5237 -DFLUTTER_ENGINE_REVISION=deb287481e -DFLUTTER_DART_VERSION=3.13.5 -DFLUTTER_WEB_USE_SKIA=true -DFLUTTER_WEB_USE_SKWASM=false -DFLUTTER_WEB_CANVASKIT_URL=https://www.gstatic.com/flutter-canvaskit/deb287481e3ce9468f3434937ced4240a70539ca/ --write-resources --native-null-assertions --no-source-maps -O4 --minify -o /home/runner/work/rezoplus-csu/rezoplus-csu/.dart_tool/flutter_build/c045b44dac70ebcc029a6dba3e3f8d17/app.dill --packages=/home/runner/work/rezoplus-csu/rezoplus-csu/.dart_tool/package_config.json --cfe-only /home/runner/work/rezoplus-csu/rezoplus-csu/.dart_tool/flutter_build/c045b44dac70ebcc029a6dba3e3f8d17/main.dart
#0      RunResult.throwException (package:flutter_tools/src/base/process.dart:153:5)
#1      _DefaultProcessUtils.run (package:flutter_tools/src/base/process.dart:379:19)
<asynchronous suspension>
#2      Dart2JSTarget.build (package:flutter_tools/src/build_system/targets/web.dart:222:5)
<asynchronous suspension>
#3      _BuildInstance._invokeInternal (package:flutter_tools/src/build_system/build_system.dart:937:9)
<asynchronous suspension>
#4      Future.wait.<anonymous closure> (dart:async/future.dart:567:21)
<asynchronous suspension>
#5      _BuildInstance.invokeTarget (package:flutter_tools/src/build_system/build_system.dart:875:32)
<asynchronous suspension>
#6      Future.wait.<anonymous closure> (dart:async/future.dart:567:21)
<asynchronous suspension>
#7      _BuildInstance.invokeTarget (package:flutter_tools/src/build_system/build_system.dart:875:32)
<asynchronous suspension>
#8      Future.wait.<anonymous closure> (dart:async/future.dart:567:21)
<asynchronous suspension>
#9      _BuildInstance.invokeTarget (package:flutter_tools/src/build_system/build_system.dart:875:32)
<asynchronous suspension>
#10     FlutterBuildSystem.build (package:flutter_tools/src/build_system/build_system.dart:684:16)
<asynchronous suspension>
#11     WebBuilder.buildWeb (package:flutter_tools/src/web/compile.dart:107:34)
<asynchronous suspension>
#12     BuildWebCommand.runCommand (package:flutter_tools/src/commands/build_web.dart:293:5)
<asynchronous suspension>
#13     FlutterCommand.run.<anonymous closure> (package:flutter_tools/src/runner/flutter_command.dart:1663:27)
<asynchronous suspension>
#14     AppContext.run.<anonymous closure> (package:flutter_tools/src/base/context.dart:154:19)
<asynchronous suspension>
#15     CommandRunner.runCommand (package:args/command_runner.dart:212:13)
<asynchronous suspension>
#16     FlutterCommandRunner.runCommand.<anonymous closure> (package:flutter_tools/src/runner/flutter_command_runner.dart:496:9)
<asynchronous suspension>
#17     AppContext.run.<anonymous closure> (package:flutter_tools/src/base/context.dart:154:19)
<asynchronous suspension>
#18     FlutterCommandRunner.runCommand (package:flutter_tools/src/runner/flutter_command_runner.dart:431:5)
<asynchronous suspension>
#19     FlutterCommandRunner.run.<anonymous closure> (package:flutter_tools/src/runner/flutter_command_runner.dart:307:33)
<asynchronous suspension>
#20     run.<anonymous closure>.<anonymous closure> (package:flutter_tools/runner.dart:104:11)
<asynchronous suspension>
#21     AppContext.run.<anonymous closure> (package:flutter_tools/src/base/context.dart:154:19)
<asynchronous suspension>
#22     main (package:flutter_tools/executable.dart:103:3)
<asynchronous suspension>

Compiling lib/main.dart for the Web...                             36.6s
Error: Failed to compile application for the Web.
Error: Process completed with exit code 1.
