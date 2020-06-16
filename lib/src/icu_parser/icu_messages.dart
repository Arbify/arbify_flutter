// Copyright 2013, the Dart project authors. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above
//       copyright notice, this list of conditions and the following
//       disclaimer in the documentation and/or other materials provided
//       with the distribution.
//     * Neither the name of Google Inc. nor the names of its
//       contributors may be used to endorse or promote products derived
//       from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// Heavily modified by Albert Wolszon.

import 'package:meta/meta.dart';

class ArgumentsList {
  final Map<String, String> _arguments = {};

  void add(String name, [String type = 'String']) {
    // Add (overrite) only when the argument isn't yet on the list
    // or if it's of type String.
    if (!_arguments.containsKey(name) || _arguments[name] == 'String') {
      _arguments[name] = type;
    }
  }

  void addAll(ArgumentsList list) {
    list.all.forEach((key, value) => add(key, value));
  }

  Map<String, String> get all => Map.unmodifiable(_arguments);
}

abstract class Message {
  final arguments = ArgumentsList();

  Message parent;

  @mustCallSuper
  Message(this.parent);

  factory Message.from(Object value, Message parent) {
    if (value is String) {
      return LiteralString(value, parent);
    } else if (value is int) {
      return VariableSubstitution(value.toString(), parent)..passArgumentsUp();
    } else if (value is List) {
      if (value.length == 1) {
        return Message.from(value[0], parent)..passArgumentsUp();
      }

      final message = CompositeMessage([], parent);
      message.pieces.addAll(
        value
            .map((value) => Message.from(value, message)..passArgumentsUp())
            .toList(),
      );

      return message..passArgumentsUp();
    }

    return (value as Message)
      ..parent = parent
      ..passArgumentsUp();
  }

  String toCode();

  void passArgumentsUp() {
    if (parent != null) {
      parent.arguments.addAll(arguments);
    }
  }

  String escapeString(String value) {
    const escapes = {
      r'\': r'\\',
      '"': r'\"',
      '\b': r'\b',
      '\f': r'\f',
      '\n': r'\n',
      '\r': r'\r',
      '\t': r'\t',
      '\v': r'\v',
      "'": r"\'",
      r'$': r'\$',
    };

    return value.splitMapJoin(
      '',
      onNonMatch: (value) => escapes[value] ?? value,
    );
  }
}

class CompositeMessage extends Message {
  List<Message> pieces;

  CompositeMessage(this.pieces, Message parent) : super(parent);

  @override
  String toCode() => pieces.map((piece) => piece.toCode()).join();
}

class LiteralString extends Message {
  String string;

  LiteralString(this.string, Message parent) : super(parent);

  @override
  String toCode() => escapeString(string);
}

class VariableSubstitution extends Message {
  String variableName;

  VariableSubstitution(this.variableName, Message parent) : super(parent) {
    arguments.add(variableName);
  }

  @override
  String toCode() => '\${$variableName}';
}

abstract class IcuMessage extends Message {
  String icuName;

  String variableName;

  Map<String, Message> clauses;

  IcuMessage(
    this.icuName,
    this.variableName,
    this.clauses,
    Message parent, {
    String variableType = 'String',
  }) : super(parent) {
    arguments.add(variableName, variableType);
  }

  @override
  String toCode() {
    final buffer = StringBuffer();
    buffer.write('\${Intl.$icuName(');
    buffer.write(variableName);
    clauses.forEach((key, value) {
      buffer.write(", $key: '${value.toCode()}'");
    });

    if (arguments.all.isNotEmpty) {
      final args = arguments.all.keys.join(', ');

      buffer.write(', args: [$args]');
    }

    buffer.write(')}');

    return buffer.toString();
  }
}

class Gender extends IcuMessage {
  Gender(String variableName, Map<String, Message> clauses, Message parent)
      : super('gender', variableName, clauses, parent);

  factory Gender.from(
    String variableName,
    List genderClauses,
    Message parent,
  ) {
    final gender = Gender(variableName, {}, parent);
    gender.clauses.addEntries(genderClauses.map(
      (clause) => MapEntry(clause[0], Message.from(clause[1], gender)),
    ));

    return gender;
  }
}

class Plural extends IcuMessage {
  Plural(
    String variableName,
    Map<String, Message> pluralClauses,
    Message parent,
  ) : super('plural', variableName, pluralClauses, parent, variableType: 'num');

  factory Plural.from(
    String variableName,
    List pluralClauses,
    Message parent,
  ) {
    final plural = Plural(variableName, {}, parent);
    plural.clauses.addEntries(pluralClauses.map(
      (clause) =>
          MapEntry(clause[0] as String, Message.from(clause[1], plural)),
    ));

    return plural;
  }
}

class Select extends IcuMessage {
  Select(
      String variableName, Map<String, Message> selectClauses, Message parent)
      : super('select', variableName, selectClauses, parent);

  factory Select.from(
    String variableName,
    List selectClauses,
    Message parent,
  ) {
    final select = Select(variableName, {}, parent);
    select.clauses.addEntries(selectClauses.map(
      (clause) =>
          MapEntry(clause[0] as String, Message.from(clause[1], select)),
    ));

    return select;
  }

  @override
  String toCode() {
    final buffer = StringBuffer();
    buffer.write('\${Intl.select(');
    buffer.write(variableName + ', cases: {');
    clauses.forEach((key, value) {
      buffer.write("'$key': '${value.toCode()}',");
    });
    buffer.write('}');

    if (arguments.all.isNotEmpty) {
      final args = arguments.all.keys.join(', ');

      buffer.write(', args: [$args]');
    }

    buffer.write(')}');

    return buffer.toString();
  }
}
