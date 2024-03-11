/*
 * Copyright (c) 2016-present Invertase Limited & Contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this library except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import 'dart:io';

import '../commands/runner.dart';
import 'base.dart';

class ExecCommand extends MelosCommand {
  ExecCommand(super.config) {
    setupPackageFilterParser();
    argParser.addOption(
      'concurrency',
      defaultsTo: Platform.numberOfProcessors.toString(),
      abbr: 'c',
    );
    argParser.addFlag(
      'fail-fast',
      abbr: 'f',
      help:
          'Whether exec should fail fast and not execute the script in further '
          'packages if the script fails in a individual package.',
    );
    argParser.addFlag(
      'order-dependents',
      abbr: 'o',
      help: 'Whether exec should order the execution of the script in multiple '
          'packages based on the dependency graph of the packages. The script '
          'will be executed in leaf packages first and then in packages that '
          'depend on them and so on. This is useful for example, for a script '
          'that generates code in multiple packages, which depend on each '
          'other.',
    );
  }

  @override
  bool get allowTrailingOptions => false;

  @override
  final String name = 'exec';

  @override
  final String description =
      'Execute an arbitrary command in each package. Supports all package '
      'filtering options.';

  @override
  Future<void> run() async {
    final execArgs = argResults!.rest;

    if (execArgs.isEmpty) {
      logger.log(description);
      logger.log(argParser.usage);
      exit(1);
    }

    final melos = Melos(logger: logger, config: config);

    final packageFilters = parsePackageFilters(config.path);
    final concurrency = int.parse(argResults!['concurrency'] as String);
    final failFast = argResults!['fail-fast'] as bool;
    final orderDependents = argResults!['order-dependents'] as bool;

    return melos.exec(
      execArgs,
      concurrency: concurrency,
      failFast: failFast,
      orderDependents: orderDependents,
      global: global,
      packageFilters: packageFilters,
    );
  }
}
